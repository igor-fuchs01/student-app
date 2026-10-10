// GET admin-get-question?id=: one question with its answer keys, in the format the editor sends
// back (AdminQuestion, docs/04-contratos-de-api.md, GET /admin/questions/:id).
import { readQueryId } from "../_shared/admin.ts";
import { sql } from "../_shared/db.ts";
import { ApiError, serveAdminEndpoint } from "../_shared/http.ts";
import type { QuestionType } from "../_shared/questions.ts";

type QuestionRow = {
  id: number;
  type: QuestionType;
  topic_id: number;
  subject_id: number;
  prompt: string | null;
  template: string | null;
  explanation: string | null;
  max_length: number | null;
  reference_answer: string | null;
  answered: boolean;
};
type OptionRow = { text: string; is_correct: boolean };
type BlankRow = { id: number; blank_key: string; reference_answer: string | null };
type BlankOptionRow = OptionRow & { blank_id: number };
type TermRow = { id: number; text: string };
type SlotRow = { slot_key: string; correct_term_id: number };

const toOption = (option: OptionRow) => ({ text: option.text, isCorrect: option.is_correct });

serveAdminEndpoint("GET", async ({ url }) => {
  const id = readQueryId(url, "Questão não encontrada.");

  const [question] = await sql<QuestionRow[]>`
    select
      q.id, q.type, q.topic_id, t.subject_id, q.prompt, q.template, q.explanation, q.max_length,
      q.reference_answer,
      exists (
        select 1 from quiz_attempt_answers answer where answer.question_id = q.id
      ) as answered
    from questions q
    join topics t on t.id = q.topic_id
    where q.id = ${id}
  `;
  if (!question) throw new ApiError(404, "NOT_FOUND", "Questão não encontrada.");

  const [options, blanks, blankOptions, terms, slots] = await Promise.all([
    sql<OptionRow[]>`
      select text, is_correct from question_options where question_id = ${id} order by order_index
    `,
    sql<BlankRow[]>`
      select id, blank_key, reference_answer from question_blanks
      where question_id = ${id}
      order by order_index
    `,
    sql<BlankOptionRow[]>`
      select bo.blank_id, bo.text, bo.is_correct
      from question_blank_options bo
      join question_blanks b on b.id = bo.blank_id
      where b.question_id = ${id}
      order by bo.order_index
    `,
    sql<TermRow[]>`
      select id, text from question_terms where question_id = ${id} order by order_index
    `,
    sql<SlotRow[]>`
      select slot_key, correct_term_id from question_slots
      where question_id = ${id}
      order by order_index
    `,
  ]);

  const base = {
    id: String(question.id),
    topicId: String(question.topic_id),
    subjectId: String(question.subject_id),
    answered: question.answered,
    type: question.type,
  };

  switch (question.type) {
    case "multiple_choice":
    case "multiple_answer":
      return {
        ...base,
        prompt: question.prompt,
        explanation: question.explanation,
        options: options.map(toOption),
      };
    case "single_choice":
      return {
        ...base,
        template: question.template,
        explanation: question.explanation,
        blanks: blanks.map((blank) => ({
          key: blank.blank_key,
          options: blankOptions.filter((option) => option.blank_id === blank.id).map(toOption),
        })),
      };
    case "drag_and_drop":
      return {
        ...base,
        template: question.template,
        explanation: question.explanation,
        terms: terms.map((term) => term.text),
        slots: slots.map((slot) => ({
          key: slot.slot_key,
          correctTerm: terms.find((term) => term.id === slot.correct_term_id)!.text,
        })),
      };
    case "essay":
      return {
        ...base,
        prompt: question.prompt,
        maxLength: question.max_length,
        referenceAnswer: question.reference_answer,
      };
    case "essay_blanks":
      return {
        ...base,
        prompt: question.prompt,
        template: question.template,
        blanks: blanks.map((blank) => ({
          key: blank.blank_key,
          referenceAnswer: blank.reference_answer,
        })),
      };
  }
});
