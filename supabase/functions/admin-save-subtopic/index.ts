// POST admin-save-subtopic: creates a subassunto in an assunto, or updates the one of the body's
// id, together with its key points and materials (docs/04-contratos-de-api.md, POST
// /admin/subtopics). The body carries the whole subassunto: the key points are replaced by the
// list sent, and a material missing from the list is deleted.
//
// A material's URL must be https: the student's screen puts it in a link, so a javascript: URL
// saved here would run in the student's browser.
import { z } from "npm:zod@4";
import { idSchema, logAdminAction, readBody, text } from "../_shared/admin.ts";
import { sql } from "../_shared/db.ts";
import { ApiError, serveAdminEndpoint } from "../_shared/http.ts";

const bodySchema = z.object({
  id: idSchema.optional(),
  topicId: idSchema,
  name: text(160),
  summary: text(2000),
  keyPoints: z.array(text(500)).max(30),
  materials: z
    .array(
      z.object({
        id: idSchema.optional(),
        title: text(200),
        fileUrl: z.url({ protocol: /^https$/ }).max(2000),
      }),
    )
    .max(30),
});

serveAdminEndpoint("POST", async ({ request, adminAuthUserId }) => {
  const { id, topicId, name, summary, keyPoints, materials } = await readBody(request, bodySchema);

  const subtopicId = await sql.begin(async (tx) => {
    if (id === undefined) {
      const [topic] = await tx<{ id: number }[]>`select id from topics where id = ${topicId}`;
      if (!topic) throw new ApiError(404, "NOT_FOUND", "Assunto não encontrado.");
    }

    const [subtopic] =
      id === undefined
        ? await tx<{ id: number }[]>`
            insert into subtopics (topic_id, name, summary, order_index)
            select ${topicId}::int, ${name}::text, ${summary}::text, coalesce(max(order_index), 0) + 1
            from subtopics
            where topic_id = ${topicId}
            returning id
          `
        : await tx<{ id: number }[]>`
            update subtopics set name = ${name}, summary = ${summary}
            where id = ${id} and topic_id = ${topicId}
            returning id
          `;
    if (!subtopic) throw new ApiError(404, "NOT_FOUND", "Subassunto não encontrado.");

    await tx`delete from subtopic_key_points where subtopic_id = ${subtopic.id}`;
    for (const [index, keyPoint] of keyPoints.entries()) {
      await tx`
        insert into subtopic_key_points (subtopic_id, text, order_index)
        values (${subtopic.id}, ${keyPoint}, ${index + 1})
      `;
    }

    const existing = await tx<{ id: number }[]>`
      select id from materials where subtopic_id = ${subtopic.id}
    `;
    for (const material of existing) {
      if (!materials.some((kept) => kept.id === material.id)) {
        await tx`delete from materials where id = ${material.id}`;
      }
    }
    for (const material of materials) {
      if (material.id === undefined) {
        await tx`
          insert into materials (subtopic_id, title, file_url)
          values (${subtopic.id}, ${material.title}, ${material.fileUrl})
        `;
      } else {
        // The subtopic filter keeps a body from rewriting a material of another subassunto.
        const [updated] = await tx<{ id: number }[]>`
          update materials set title = ${material.title}, file_url = ${material.fileUrl}
          where id = ${material.id} and subtopic_id = ${subtopic.id}
          returning id
        `;
        if (!updated) throw new ApiError(404, "NOT_FOUND", "Material não encontrado.");
      }
    }

    await logAdminAction(
      tx,
      adminAuthUserId,
      id === undefined ? "create" : "update",
      "subtopics",
      subtopic.id,
    );
    return subtopic.id;
  });

  return { id: String(subtopicId) };
});
