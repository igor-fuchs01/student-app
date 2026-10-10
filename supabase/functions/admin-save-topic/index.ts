// POST admin-save-topic: creates an assunto in a subject, or updates the one of the body's id
// (docs/04-contratos-de-api.md, POST /admin/topics). An assunto never moves to another subject:
// its questions and exercise lists would be left pointing at the old one.
import { z } from "npm:zod@4";
import { idSchema, logAdminAction, readBody, text } from "../_shared/admin.ts";
import { sql } from "../_shared/db.ts";
import { ApiError, serveAdminEndpoint } from "../_shared/http.ts";

const bodySchema = z.object({
  id: idSchema.optional(),
  subjectId: idSchema,
  number: z.number().int().min(1).max(999),
  name: text(160),
  description: text(500),
});

serveAdminEndpoint("POST", async ({ request, adminAuthUserId }) => {
  const { id, subjectId, number, name, description } = await readBody(request, bodySchema);

  const topicId = await sql.begin(async (tx) => {
    if (id === undefined) {
      const [subject] = await tx<{ id: number }[]>`select id from subjects where id = ${subjectId}`;
      if (!subject) throw new ApiError(404, "NOT_FOUND", "Disciplina não encontrada.");
    }

    const [topic] =
      id === undefined
        ? await tx<{ id: number }[]>`
            insert into topics (subject_id, number, name, description)
            values (${subjectId}, ${number}, ${name}, ${description})
            returning id
          `
        : await tx<{ id: number }[]>`
            update topics set number = ${number}, name = ${name}, description = ${description}
            where id = ${id} and subject_id = ${subjectId}
            returning id
          `;
    if (!topic) throw new ApiError(404, "NOT_FOUND", "Assunto não encontrado.");

    await logAdminAction(
      tx,
      adminAuthUserId,
      id === undefined ? "create" : "update",
      "topics",
      topic.id,
    );
    return topic.id;
  });

  return { id: String(topicId) };
});
