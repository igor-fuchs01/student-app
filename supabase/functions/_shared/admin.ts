// What every admin-* edge function shares: reading a validated body, the audit log and the
// delete endpoint. The authorization itself is serveAdminEndpoint, in http.ts.
import type postgres from "npm:postgres@3";
import { z } from "npm:zod@4";
import { sql } from "./db.ts";
import { ApiError, serveAdminEndpoint } from "./http.ts";

// The admin reads the validation messages as they are, so zod writes them in Portuguese.
z.config(z.locales.pt());

export type Tx = postgres.TransactionSql;

// Tables the admin writes to; also the entity recorded in admin_audit_log.
type AdminEntity = "subjects" | "topics" | "subtopics" | "questions" | "quizzes";

// Database ids travel as numeric strings; nine digits always fit an integer.
export const idSchema = z
  .string()
  .regex(/^\d{1,9}$/)
  .transform(Number);

export const text = (maxLength: number) => z.string().trim().min(1).max(maxLength);

// One line per problem, each led by where it is in the body ("questions.2.options: ...").
function validationError(error: z.ZodError): ApiError {
  const lines = error.issues
    .slice(0, 12)
    .map((issue) => (issue.path.length ? `${issue.path.join(".")}: ` : "") + issue.message);
  return new ApiError(400, "VALIDATION_ERROR", lines.join("\n"));
}

export async function readBody<T>(request: Request, schema: z.ZodType<T>): Promise<T> {
  const body = schema.safeParse(await request.json().catch(() => null));
  if (!body.success) throw validationError(body.error);
  return body.data;
}

// The ?id= of a GET; one that isn't numeric answers 404, like an unknown resource.
export function readQueryId(url: URL, notFoundMessage: string): number {
  const id = url.searchParams.get("id") ?? "";
  if (!/^\d{1,9}$/.test(id)) throw new ApiError(404, "NOT_FOUND", notFoundMessage);
  return Number(id);
}

// Written in the transaction of the write it records, so neither exists without the other.
export async function logAdminAction(
  tx: Tx,
  adminAuthUserId: string,
  action: "create" | "update" | "delete" | "import",
  entity: AdminEntity,
  entityId: number,
): Promise<void> {
  await tx`
    insert into admin_audit_log (admin_auth_user_id, action, entity, entity_id)
    values (${adminAuthUserId}, ${action}, ${entity}, ${entityId})
  `;
}

// POST { id }: deletes one row. The foreign keys decide what may go: a row that questions,
// quizzes or student answers still depend on is refused by the database and answers 409
// (toConflict in http.ts), so the admin can never erase a student's history.
export function serveAdminDelete(entity: AdminEntity, notFoundMessage: string): void {
  serveAdminEndpoint("POST", async ({ request, adminAuthUserId }) => {
    const { id } = await readBody(request, z.object({ id: idSchema }));

    await sql.begin(async (tx) => {
      const [row] = await tx<{ id: number }[]>`
        delete from ${tx(entity)} where id = ${id} returning id
      `;
      if (!row) throw new ApiError(404, "NOT_FOUND", notFoundMessage);
      await logAdminAction(tx, adminAuthUserId, "delete", entity, id);
    });

    return { id: String(id) };
  });
}
