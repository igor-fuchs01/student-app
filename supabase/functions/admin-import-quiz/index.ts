// POST admin-import-quiz: creates a simulado or an exercise list together with its questions from
// one JSON document (docs/04-contratos-de-api.md, POST /admin/quizzes/import). It is the format
// of supabase/scripts/import-quiz.sql, with the same rules:
//   * the whole document is validated first and nothing is written when anything is wrong;
//   * the subject and the assuntos are found by name and never created here, so a typo cannot
//     create a duplicate beside the real one;
//   * the questions are always new rows.
import { z } from "npm:zod@4";
import { logAdminAction, readBody, text } from "../_shared/admin.ts";
import { insertQuestion, questionInputSchema } from "../_shared/adminQuestions.ts";
import {
  assertTitleAvailable,
  kindProblems,
  quizFields,
  writeQuizQuestions,
} from "../_shared/adminQuizzes.ts";
import { sql } from "../_shared/db.ts";
import { ApiError, serveAdminEndpoint } from "../_shared/http.ts";

const subjectName = text(120);
const topicName = text(160);

const bodySchema = z
  .object({
    ...quizFields,
    kind: quizFields.kind.default("exam"),
    subject: subjectName,
    topic: topicName.optional(),
    questions: z
      .array(
        z
          .object({ subject: subjectName.optional(), topic: topicName.optional() })
          .and(questionInputSchema),
      )
      .min(1)
      .max(200),
  })
  .superRefine((quiz, context) => {
    for (const message of kindProblems(quiz.kind, quiz.durationMinutes, quiz.topic !== undefined)) {
      context.addIssue({ code: "custom", message });
    }
    for (const [index, question] of quiz.questions.entries()) {
      const path = ["questions", index];
      if (question.subject !== undefined && question.subject !== quiz.subject) {
        context.addIssue({
          code: "custom",
          path,
          message: "Toda questão precisa ser da disciplina do simulado.",
        });
      }
      // In an exercise list a question may omit its assunto: it is the list's.
      if (quiz.kind === "exam" && question.topic === undefined) {
        context.addIssue({ code: "custom", path, message: 'Informe o assunto em "topic".' });
      }
      if (quiz.kind === "exercise" && (question.topic ?? quiz.topic) !== quiz.topic) {
        context.addIssue({
          code: "custom",
          path,
          message: "Toda questão de uma lista de exercícios precisa ser do assunto dela.",
        });
      }
    }
  });

serveAdminEndpoint("POST", async ({ request, adminAuthUserId }) => {
  const quiz = await readBody(request, bodySchema);

  const quizId = await sql.begin(async (tx) => {
    const [subject] = await tx<{ id: number }[]>`
      select id from subjects where name = ${quiz.subject}
    `;
    if (!subject) {
      throw new ApiError(
        400,
        "VALIDATION_ERROR",
        `A disciplina "${quiz.subject}" não foi encontrada.`,
      );
    }

    const topics = await tx<{ id: number; name: string }[]>`
      select id, name from topics where subject_id = ${subject.id}
    `;
    const topicIds = new Map(topics.map((topic) => [topic.name, topic.id]));
    const usedTopics = [quiz.topic, ...quiz.questions.map((question) => question.topic)].filter(
      (name) => name !== undefined,
    );
    const unknownTopics = [...new Set(usedTopics)].filter((name) => !topicIds.has(name));
    if (unknownTopics.length > 0) {
      throw new ApiError(
        400,
        "VALIDATION_ERROR",
        unknownTopics
          .map((name) => `O assunto "${name}" não foi encontrado em "${quiz.subject}".`)
          .join("\n"),
      );
    }

    await assertTitleAvailable(tx, quiz.title);

    const quizTopicId = quiz.topic === undefined ? null : topicIds.get(quiz.topic)!;
    const [created] = await tx<{ id: number }[]>`
      insert into quizzes (title, kind, subject_id, topic_id, duration_minutes, difficulty)
      values (
        ${quiz.title}, ${quiz.kind}, ${subject.id}, ${quizTopicId},
        ${quiz.durationMinutes ?? null}, ${quiz.difficulty}
      )
      returning id
    `;

    const questionIds: number[] = [];
    for (const { topic, ...question } of quiz.questions) {
      const topicId = topicIds.get(topic ?? quiz.topic!)!;
      questionIds.push(await insertQuestion(tx, topicId, question));
    }
    await writeQuizQuestions(tx, created.id, questionIds);

    await logAdminAction(tx, adminAuthUserId, "import", "quizzes", created.id);
    return created.id;
  });

  return { id: String(quizId) };
});
