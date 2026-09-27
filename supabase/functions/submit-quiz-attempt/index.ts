// POST submit-quiz-attempt: grades a quiz attempt and returns its QuizResult
// (docs/04-contratos-de-api.md §3.14, POST /quizzes/:id/attempts).
//
// zod checks the shape of the body; grade.ts checks every answer against the quiz's answer keys
// and grades it; the attempt, its answers and the study day are then written in one transaction,
// so a failure leaves nothing behind. The result is computed here from the graded answers.
import { z } from "npm:zod@4";
import { sql } from "../_shared/db.ts";
import { ApiError, serveEndpoint } from "../_shared/http.ts";
import { loadQuizQuestions, type QuizQuestion } from "../_shared/questions.ts";
import { gradeAnswer, invalidAnswers, type GradedAnswer } from "./grade.ts";

// Database ids travel as numeric strings; nine digits always fit an integer.
const id = z.string().regex(/^\d{1,9}$/);
// An empty value is a blank the student left unanswered; the grading counts it as such instead
// of rejecting it.
const idOrEmpty = z.string().regex(/^\d{0,9}$/);

// Same fields as quizAnswerSchema in src/types/quizzes.ts, with the bounds the server needs. The
// texts are safety ceilings, not rules the student is meant to feel: an essay is also held to its
// own questions.max_length.
const answerSchema = z.object({
  questionId: id,
  optionId: idOrEmpty.optional(),
  optionIds: z.array(id).max(50).optional(),
  text: z.string().max(20000).optional(),
  blankAnswers: z.record(z.string().max(64), z.string().max(2000)).optional(),
  slotAnswers: z.record(z.string().max(64), idOrEmpty).optional(),
});

const bodySchema = z.object({
  quizId: id,
  answers: z.array(answerSchema).max(200),
});

// Hits over graded answers, rounded to two decimals; null when nothing was graded.
function percent(part: number, total: number): number | null {
  return total === 0 ? null : Math.round((10000 * part) / total) / 100;
}

// Replaces each {{key}} of a template with its value; unknown keys become "___".
function fillTemplate(template: string, values: Record<string, string>): string {
  return template.replace(/\{\{(\w+)\}\}/g, (_placeholder, key: string) => values[key] ?? "___");
}

// QuizReviewItem.promptExcerpt, same rule as the mock server.
function promptExcerpt(question: QuizQuestion): string {
  const text =
    question.type === "single_choice" || question.type === "drag_and_drop"
      ? fillTemplate(question.template!, {})
      : question.type === "essay_blanks"
        ? `${question.prompt} ${fillTemplate(question.template!, {})}`
        : question.prompt!;
  return text.length <= 90 ? text : `${text.slice(0, 89).replace(/\s+$/, "")}…`;
}

// pending_review answers are left out of the score; unanswered questions count in the
// denominator.
function score(questions: QuizQuestion[], graded: Map<number, GradedAnswer>): number | null {
  const statuses = questions.map((question) => graded.get(question.id)?.status);
  return percent(
    statuses.filter((status) => status === "correct").length,
    statuses.filter((status) => status !== "pending_review").length,
  );
}

function reviewItem({ question, status, essayText, blanks }: GradedAnswer) {
  const pending = status === "pending_review";
  const studentBlanks = Object.fromEntries(blanks.map((blank) => [blank.blankKey, blank.text!]));
  const referenceBlanks = Object.fromEntries(
    question.blanks.map((blank) => [blank.blank_key, blank.reference_answer!]),
  );

  return {
    questionId: String(question.id),
    subjectName: question.subjectName,
    promptExcerpt: promptExcerpt(question),
    status: pending ? "self_review" : "incorrect",
    explanation: pending ? undefined : (question.explanation ?? undefined),
    studentAnswer: !pending
      ? undefined
      : question.type === "essay"
        ? essayText!.trim()
        : fillTemplate(question.template!, studentBlanks),
    referenceAnswer: !pending
      ? undefined
      : question.type === "essay"
        ? question.referenceAnswer!
        : fillTemplate(question.template!, referenceBlanks),
  };
}

serveEndpoint("POST", async ({ request, studentId }) => {
  const body = bodySchema.safeParse(await request.json().catch(() => null));
  if (!body.success) throw invalidAnswers();

  const quizId = Number(body.data.quizId);
  const questions = await loadQuizQuestions(quizId);
  if (questions.length === 0) throw new ApiError(404, "NOT_FOUND", "Simulado não encontrado.");

  const questionsById = new Map(questions.map((question) => [question.id, question]));
  const graded = new Map<number, GradedAnswer>();
  const seen = new Set<number>();
  for (const answer of body.data.answers) {
    const question = questionsById.get(Number(answer.questionId));
    if (!question || seen.has(question.id)) throw invalidAnswers();
    seen.add(question.id);

    const result = gradeAnswer(question, answer);
    if (result) graded.set(question.id, result);
  }

  const submittedAt = await sql.begin(async (tx) => {
    const [attempt] = await tx<{ id: number; submitted_at: Date }[]>`
      insert into quiz_attempts (quiz_id, student_id)
      values (${quizId}, ${studentId})
      returning id, submitted_at
    `;

    for (const answer of graded.values()) {
      const [row] = await tx<{ id: number }[]>`
        insert into quiz_attempt_answers
          (attempt_id, question_id, selected_option_id, essay_text, review_status)
        values (
          ${attempt.id}, ${answer.question.id}, ${answer.selectedOptionId},
          ${answer.essayText}, ${answer.status}
        )
        returning id
      `;
      for (const optionId of answer.optionIds) {
        await tx`
          insert into quiz_attempt_answer_options (answer_id, option_id)
          values (${row.id}, ${optionId})
        `;
      }
      for (const blank of answer.blanks) {
        await tx`
          insert into quiz_attempt_answer_blanks (answer_id, blank_id, selected_option_id, text)
          values (${row.id}, ${blank.blankId}, ${blank.selectedOptionId}, ${blank.text})
        `;
      }
      for (const slot of answer.slots) {
        await tx`
          insert into quiz_attempt_answer_slots (answer_id, slot_id, term_id)
          values (${row.id}, ${slot.slotId}, ${slot.termId})
        `;
      }
    }

    await tx`
      insert into student_activity_days (student_id, activity_date)
      values (${studentId}, current_date)
      on conflict do nothing
    `;
    return attempt.submitted_at;
  });

  const statuses = [...graded.values()].map((answer) => answer.status);
  const subjects = [...new Map(questions.map((q) => [q.subjectId, q.subjectName])).entries()];

  return {
    quizId: String(quizId),
    submittedAt: submittedAt.toISOString(),
    correctCount: statuses.filter((status) => status === "correct").length,
    incorrectCount: statuses.filter((status) => status === "incorrect").length,
    unansweredCount: questions.length - graded.size,
    selfReviewCount: statuses.filter((status) => status === "pending_review").length,
    scorePercent: score(questions, graded) ?? 0,
    subjectPerformance: subjects
      .map(([subjectId, subjectName]) => ({
        subjectName,
        percent: score(
          questions.filter((question) => question.subjectId === subjectId),
          graded,
        ),
      }))
      .filter((performance) => performance.percent !== null)
      .sort((a, b) => a.subjectName.localeCompare(b.subjectName, "pt-BR")),
    reviewItems: questions
      .map((question) => graded.get(question.id))
      .filter((answer) => answer && answer.status !== "correct")
      .map((answer) => reviewItem(answer!)),
  };
});
