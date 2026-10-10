// POST admin-save-subject: creates a subject, or updates the one of the body's id
// (docs/04-contratos-de-api.md, POST /admin/subjects). The name is unique, because the quiz
// import finds a subject by it.
import { z } from "npm:zod@4";
import { idSchema, logAdminAction, readBody, text } from "../_shared/admin.ts";
import { sql } from "../_shared/db.ts";
import { ApiError, serveAdminEndpoint } from "../_shared/http.ts";

const bodySchema = z.object({
  id: idSchema.optional(),
  name: text(120),
  shortLabel: text(12),
});

serveAdminEndpoint("POST", async ({ request, adminAuthUserId }) => {
  const { id, name, shortLabel } = await readBody(request, bodySchema);

  const subjectId = await sql.begin(async (tx) => {
    const [sameName] = await tx<{ id: number }[]>`
      select id from subjects where name = ${name} and id is distinct from ${id ?? null}
    `;
    if (sameName) throw new ApiError(409, "CONFLICT", "Já existe uma disciplina com esse nome.");

    const [subject] =
      id === undefined
        ? await tx<{ id: number }[]>`
            insert into subjects (name, short_label) values (${name}, ${shortLabel}) returning id
          `
        : await tx<{ id: number }[]>`
            update subjects set name = ${name}, short_label = ${shortLabel}
            where id = ${id}
            returning id
          `;
    if (!subject) throw new ApiError(404, "NOT_FOUND", "Disciplina não encontrada.");

    await logAdminAction(
      tx,
      adminAuthUserId,
      id === undefined ? "create" : "update",
      "subjects",
      subject.id,
    );
    return subject.id;
  });

  return { id: String(subjectId) };
});
