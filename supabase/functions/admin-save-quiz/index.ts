// POST admin-save-quiz: creates a simulado or an exercise list, or updates the one of the body's
// id, with the questions it holds (docs/04-contratos-de-api.md, POST /admin/quizzes).
//
// questionIds is the whole list, in display order: it replaces the questions the quiz had. Every
// question must be of the quiz's subject and, in an exercise list, of its assunto.
import { z } from "npm:zod@4";
import { idSchema, logAdminAction, readBody } from "../_shared/admin.ts";
import {
  assertTitleAvailable,
  kindProblems,
  quizFields,
  writeQuizQuestions,
} from "../_shared/adminQuizzes.ts";
import { sql } from "../_shared/db.ts";
import { ApiError, serveAdminEndpoint } from "../_shared/http.ts";

const bodySchema = z
  .object({
    ...quizFields,
    id: idSchema.optional(),
    subjectId: idSchema,
    topicId: idSchema.optional(),
    questionIds: z.array(idSchema).min(1).max(200),
  })
  .superRefine((quiz, context) => {
    for (const message of kindProblems(quiz.kind, quiz.durationMinutes, quiz.topicId !== undefined)) {
      context.addIssue({ code: "custom", message });
    }
    if (new Set(quiz.questionIds).size !== quiz.questionIds.length) {
      context.addIssue({
        code: "custom",
        path: ["questionIds"],
        message: "A mesma questão aparece mais de uma vez.",
      });
    }
  });

function invalid(message: string): ApiError {
  return new ApiError(400, "VALIDATION_ERROR", message);
}

serveAdminEndpoint("POST", async ({ request, adminAuthUserId }) => {
  const quiz = await readBody(request, bodySchema);
  const topicId = quiz.topicId ?? null;
  const durationMinutes = quiz.durationMinutes ?? null;

  const quizId = await sql.begin(async (tx) => {
    const [subject] = await tx<{ id: number }[]>`
      select id from subjects where id = ${quiz.subjectId}
    `;
    if (!subject) throw new ApiError(404, "NOT_FOUND", "Disciplina não encontrada.");

    if (topicId !== null) {
      const [topic] = await tx<{ id: number }[]>`
        select id from topics where id = ${topicId} and subject_id = ${quiz.subjectId}
      `;
      if (!topic) throw invalid("O assunto não pertence à disciplina da lista.");
    }

    const questions = await tx<{ id: number; topic_id: number; subject_id: number }[]>`
      select q.id, q.topic_id, t.subject_id
      from questions q
      join topics t on t.id = q.topic_id
      where q.id in ${tx(quiz.questionIds)}
    `;
    if (questions.length !== quiz.questionIds.length) {
      throw invalid("Uma das questões não existe mais. Recarregue a página.");
    }
    if (questions.some((question) => question.subject_id !== quiz.subjectId)) {
      throw invalid("Todas as questões precisam ser da disciplina do simulado.");
    }
    if (topicId !== null && questions.some((question) => question.topic_id !== topicId)) {
      throw invalid("Todas as questões de uma lista de exercícios precisam ser do assunto dela.");
    }

    await assertTitleAvailable(tx, quiz.title, quiz.id);

    const [saved] =
      quiz.id === undefined
        ? await tx<{ id: number }[]>`
            insert into quizzes (title, kind, subject_id, topic_id, duration_minutes, difficulty)
            values (
              ${quiz.title}, ${quiz.kind}, ${quiz.subjectId}, ${topicId}, ${durationMinutes},
              ${quiz.difficulty}
            )
            returning id
          `
        : await tx<{ id: number }[]>`
            update quizzes
            set title = ${quiz.title}, kind = ${quiz.kind}, subject_id = ${quiz.subjectId},
              topic_id = ${topicId}, duration_minutes = ${durationMinutes},
              difficulty = ${quiz.difficulty}
            where id = ${quiz.id}
            returning id
          `;
    if (!saved) throw new ApiError(404, "NOT_FOUND", "Simulado não encontrado.");

    await writeQuizQuestions(tx, saved.id, quiz.questionIds);
    await logAdminAction(
      tx,
      adminAuthUserId,
      quiz.id === undefined ? "create" : "update",
      "quizzes",
      saved.id,
    );
    return saved.id;
  });

  return { id: String(quizId) };
});
