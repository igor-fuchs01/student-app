// POST admin-save-question: creates a question in an assunto, or updates the one of the body's
// id (docs/04-contratos-de-api.md, POST /admin/questions).
//
// An update keeps the question's type, and keeps its assunto while a quiz uses it: a quiz only
// holds questions of its own subject (and an exercise list, of its own assunto). The rows of
// options, blanks, terms and slots are updated in place, so fixing a text works on a question
// students already answered; removing a row that a student's answer points at is refused by the
// database and answers 409.
import { z } from "npm:zod@4";
import { idSchema, logAdminAction, readBody } from "../_shared/admin.ts";
import { insertQuestion, questionInputSchema, updateQuestion } from "../_shared/adminQuestions.ts";
import { sql } from "../_shared/db.ts";
import { ApiError, serveAdminEndpoint } from "../_shared/http.ts";

const bodySchema = z
  .object({ id: idSchema.optional(), topicId: idSchema })
  .and(questionInputSchema);

serveAdminEndpoint("POST", async ({ request, adminAuthUserId }) => {
  const { id, topicId, ...question } = await readBody(request, bodySchema);

  const questionId = await sql.begin(async (tx) => {
    const [topic] = await tx<{ id: number }[]>`select id from topics where id = ${topicId}`;
    if (!topic) throw new ApiError(404, "NOT_FOUND", "Assunto não encontrado.");

    if (id === undefined) {
      const createdId = await insertQuestion(tx, topicId, question);
      await logAdminAction(tx, adminAuthUserId, "create", "questions", createdId);
      return createdId;
    }

    const [existing] = await tx<{ type: string; topic_id: number; in_quiz: boolean }[]>`
      select
        q.type, q.topic_id,
        exists (select 1 from quiz_questions qq where qq.question_id = q.id) as in_quiz
      from questions q
      where q.id = ${id}
      for update
    `;
    if (!existing) throw new ApiError(404, "NOT_FOUND", "Questão não encontrada.");
    if (existing.type !== question.type) {
      throw new ApiError(
        400,
        "VALIDATION_ERROR",
        "O tipo de uma questão não pode ser alterado. Crie uma nova questão.",
      );
    }
    if (existing.topic_id !== topicId && existing.in_quiz) {
      throw new ApiError(
        409,
        "CONFLICT",
        "Esta questão está em um simulado ou lista. Remova-a de lá antes de trocar o assunto.",
      );
    }

    await updateQuestion(tx, id, topicId, question);
    await logAdminAction(tx, adminAuthUserId, "update", "questions", id);
    return id;
  });

  return { id: String(questionId) };
});
