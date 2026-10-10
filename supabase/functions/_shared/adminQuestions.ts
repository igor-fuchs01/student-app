// A question as the admin writes it (AdminQuestionInput, docs/04-contratos-de-api.md): the same
// JSON of supabase/scripts/import-quiz.sql, with the same rules, used by the question editor
// (admin-save-question) and by the quiz import (admin-import-quiz).
import { z } from "npm:zod@4";
import { text, type Tx } from "./admin.ts";
import { sql } from "./db.ts";
import type { QuestionType } from "./questions.ts";

const statement = text(5000);
// A {{key}} of a template; \w is what the student's screen and the grading read as a placeholder.
const key = z.string().regex(/^\w{1,32}$/);
const options = z
  .array(z.object({ text: text(1000), isCorrect: z.boolean() }))
  .min(2)
  .max(12);

type Option = z.infer<typeof options>[number];

const questionShapes = z.discriminatedUnion("type", [
  z.object({
    type: z.literal("multiple_choice"),
    prompt: statement,
    explanation: statement,
    options,
  }),
  z.object({
    type: z.literal("multiple_answer"),
    prompt: statement,
    explanation: statement,
    options,
  }),
  z.object({
    type: z.literal("single_choice"),
    template: statement,
    explanation: statement,
    blanks: z.array(z.object({ key, options })).min(1).max(20),
  }),
  z.object({
    type: z.literal("drag_and_drop"),
    template: statement,
    explanation: statement,
    terms: z.array(text(300)).min(2).max(20),
    slots: z.array(z.object({ key, correctTerm: text(300) })).min(1).max(20),
  }),
  z.object({
    type: z.literal("essay"),
    prompt: statement,
    // The ceiling submit-quiz-attempt accepts for an essay text.
    maxLength: z.number().int().min(1).max(20000),
    referenceAnswer: statement,
  }),
  z.object({
    type: z.literal("essay_blanks"),
    prompt: statement,
    template: statement,
    blanks: z.array(z.object({ key, referenceAnswer: text(2000) })).min(1).max(20),
  }),
]);

export type QuestionInput = z.infer<typeof questionShapes>;

type Problem = { path: (string | number)[]; message: string };

function correctCount(list: Option[]): number {
  return list.filter((option) => option.isCorrect).length;
}

// The {{key}} placeholders of a template and the keys the question declares must match one to
// one, or the student would see a blank nothing answers.
function placeholderProblems(template: string, keys: string[], label: string): Problem[] {
  const used = new Set([...template.matchAll(/\{\{(\w+)\}\}/g)].map((match) => match[1]));
  const problems: Problem[] = [];

  for (const [index, declared] of keys.entries()) {
    if (keys.indexOf(declared) !== index) {
      problems.push({ path: [label], message: `A chave "${declared}" está repetida.` });
    } else if (!used.has(declared)) {
      problems.push({
        path: ["template"],
        message: `O texto não tem a marcação {{${declared}}}.`,
      });
    }
  }
  for (const placeholder of used) {
    if (!keys.includes(placeholder)) {
      problems.push({
        path: ["template"],
        message: `A marcação {{${placeholder}}} não tem lacuna correspondente.`,
      });
    }
  }
  return problems;
}

function questionProblems(question: QuestionInput): Problem[] {
  const oneCorrect = "Marque exatamente uma alternativa correta.";

  switch (question.type) {
    case "multiple_choice":
      return correctCount(question.options) === 1 ? [] : [{ path: ["options"], message: oneCorrect }];
    case "multiple_answer":
      return correctCount(question.options) >= 1
        ? []
        : [{ path: ["options"], message: "Marque pelo menos uma alternativa correta." }];
    case "single_choice":
      return [
        ...placeholderProblems(
          question.template,
          question.blanks.map((blank) => blank.key),
          "blanks",
        ),
        ...question.blanks
          .map((blank, index) => ({ blank, index }))
          .filter(({ blank }) => correctCount(blank.options) !== 1)
          .map(({ index }) => ({ path: ["blanks", index, "options"], message: oneCorrect })),
      ];
    case "drag_and_drop":
      return [
        ...placeholderProblems(
          question.template,
          question.slots.map((slot) => slot.key),
          "slots",
        ),
        // The slots point at a term by its text, so two identical terms would be ambiguous.
        ...(new Set(question.terms).size === question.terms.length
          ? []
          : [{ path: ["terms"], message: "Cada termo deve ser único." }]),
        ...question.slots
          .map((slot, index) => ({ slot, index }))
          .filter(({ slot }) => !question.terms.includes(slot.correctTerm))
          .map(({ index }) => ({
            path: ["slots", index, "correctTerm"],
            message: "O termo correto precisa estar na lista de termos.",
          })),
      ];
    case "essay":
      return [];
    case "essay_blanks":
      return placeholderProblems(
        question.template,
        question.blanks.map((blank) => blank.key),
        "blanks",
      );
  }
}

export const questionInputSchema = questionShapes.superRefine((question, context) => {
  for (const problem of questionProblems(question)) {
    context.addIssue({ code: "custom", path: problem.path, message: problem.message });
  }
});

// Only the columns the type uses are filled; the CHECK constraints of questions reject anything
// else.
function statementColumns(question: QuestionInput) {
  return {
    prompt: "prompt" in question ? question.prompt : null,
    template: "template" in question ? question.template : null,
    explanation: "explanation" in question ? question.explanation : null,
    maxLength: question.type === "essay" ? question.maxLength : null,
    referenceAnswer: question.type === "essay" ? question.referenceAnswer : null,
  };
}

type OrderedRow = { id: number; order_index: number };

// Options are matched to the existing rows by position: a row is updated in place, so the answers
// students already gave keep pointing at it. Removing one that an answer points at is refused by the
// foreign key, and the endpoint answers 409.
async function syncOptions(
  tx: Tx,
  table: "question_options" | "question_blank_options",
  parentColumn: "question_id" | "blank_id",
  parentId: number,
  list: Option[],
): Promise<void> {
  const existing = await tx<OrderedRow[]>`
    select id, order_index from ${tx(table)}
    where ${tx(parentColumn)} = ${parentId}
    order by order_index
  `;
  for (const row of existing.slice(list.length)) {
    await tx`delete from ${tx(table)} where id = ${row.id}`;
  }

  let orderIndex = existing.at(-1)?.order_index ?? 0;
  for (const [index, option] of list.entries()) {
    const row = existing[index];
    if (row) {
      await tx`
        update ${tx(table)} set text = ${option.text}, is_correct = ${option.isCorrect}
        where id = ${row.id}
      `;
    } else {
      orderIndex += 1;
      await tx`
        insert into ${tx(table)} (${tx(parentColumn)}, text, is_correct, order_index)
        values (${parentId}, ${option.text}, ${option.isCorrect}, ${orderIndex})
      `;
    }
  }
}

// Blanks are matched by their key, which is what the template refers to.
async function syncBlanks(
  tx: Tx,
  questionId: number,
  blanks: { key: string; options?: Option[]; referenceAnswer?: string }[],
): Promise<void> {
  const existing = await tx<{ id: number; blank_key: string }[]>`
    select id, blank_key from question_blanks where question_id = ${questionId}
  `;
  for (const row of existing) {
    if (!blanks.some((blank) => blank.key === row.blank_key)) {
      await tx`delete from question_blanks where id = ${row.id}`;
    }
  }

  for (const [index, blank] of blanks.entries()) {
    const referenceAnswer = blank.referenceAnswer ?? null;
    const row = existing.find((candidate) => candidate.blank_key === blank.key);
    const [saved] = row
      ? await tx<{ id: number }[]>`
          update question_blanks
          set reference_answer = ${referenceAnswer}, order_index = ${index + 1}
          where id = ${row.id}
          returning id
        `
      : await tx<{ id: number }[]>`
          insert into question_blanks (question_id, blank_key, reference_answer, order_index)
          values (${questionId}, ${blank.key}, ${referenceAnswer}, ${index + 1})
          returning id
        `;
    if (blank.options) {
      await syncOptions(tx, "question_blank_options", "blank_id", saved.id, blank.options);
    }
  }
}

// Terms by position, slots by key. A term is only deleted after the slots stopped pointing at
// it: question_slots.correct_term_id cascades, and would take the slot along.
async function syncTermsAndSlots(
  tx: Tx,
  questionId: number,
  terms: string[],
  slots: { key: string; correctTerm: string }[],
): Promise<void> {
  const existingTerms = await tx<OrderedRow[]>`
    select id, order_index from question_terms
    where question_id = ${questionId}
    order by order_index
  `;
  const termIds = new Map<string, number>();
  let orderIndex = existingTerms.at(-1)?.order_index ?? 0;
  for (const [index, term] of terms.entries()) {
    const row = existingTerms[index];
    if (row) {
      await tx`update question_terms set text = ${term} where id = ${row.id}`;
      termIds.set(term, row.id);
    } else {
      orderIndex += 1;
      const [inserted] = await tx<{ id: number }[]>`
        insert into question_terms (question_id, text, order_index)
        values (${questionId}, ${term}, ${orderIndex})
        returning id
      `;
      termIds.set(term, inserted.id);
    }
  }

  const existingSlots = await tx<{ id: number; slot_key: string }[]>`
    select id, slot_key from question_slots where question_id = ${questionId}
  `;
  for (const row of existingSlots) {
    if (!slots.some((slot) => slot.key === row.slot_key)) {
      await tx`delete from question_slots where id = ${row.id}`;
    }
  }
  for (const [index, slot] of slots.entries()) {
    const termId = termIds.get(slot.correctTerm)!;
    const row = existingSlots.find((candidate) => candidate.slot_key === slot.key);
    if (row) {
      await tx`
        update question_slots set correct_term_id = ${termId}, order_index = ${index + 1}
        where id = ${row.id}
      `;
    } else {
      await tx`
        insert into question_slots (question_id, slot_key, correct_term_id, order_index)
        values (${questionId}, ${slot.key}, ${termId}, ${index + 1})
      `;
    }
  }

  for (const row of existingTerms.slice(terms.length)) {
    await tx`delete from question_terms where id = ${row.id}`;
  }
}

async function syncChildren(tx: Tx, questionId: number, question: QuestionInput): Promise<void> {
  switch (question.type) {
    case "multiple_choice":
    case "multiple_answer":
      return syncOptions(tx, "question_options", "question_id", questionId, question.options);
    case "single_choice":
    case "essay_blanks":
      return syncBlanks(tx, questionId, question.blanks);
    case "drag_and_drop":
      return syncTermsAndSlots(tx, questionId, question.terms, question.slots);
    case "essay":
      return;
  }
}

export async function insertQuestion(
  tx: Tx,
  topicId: number,
  question: QuestionInput,
): Promise<number> {
  const columns = statementColumns(question);
  const [row] = await tx<{ id: number }[]>`
    insert into questions
      (topic_id, type, prompt, template, explanation, max_length, reference_answer)
    values (
      ${topicId}, ${question.type}, ${columns.prompt}, ${columns.template},
      ${columns.explanation}, ${columns.maxLength}, ${columns.referenceAnswer}
    )
    returning id
  `;
  await syncChildren(tx, row.id, question);
  return row.id;
}

// The question keeps its type: the caller refuses a body of another one.
export async function updateQuestion(
  tx: Tx,
  questionId: number,
  topicId: number,
  question: QuestionInput,
): Promise<void> {
  const columns = statementColumns(question);
  await tx`
    update questions
    set topic_id = ${topicId}, prompt = ${columns.prompt}, template = ${columns.template},
      explanation = ${columns.explanation}, max_length = ${columns.maxLength},
      reference_answer = ${columns.referenceAnswer}
    where id = ${questionId}
  `;
  await syncChildren(tx, questionId, question);
}

type QuestionSummaryRow = {
  id: number;
  type: QuestionType;
  statement: string;
  topic_id: number;
  topic_number: number;
  topic_name: string;
  subject_id: number;
  subject_name: string;
  quiz_count: number;
  answered: boolean;
};

type QuestionSummaryFilter = { subjectId?: number; topicId?: number; quizId?: number };

// AdminQuestionSummary[]: the questions of a subject, an assunto or a quiz. Those of a quiz come
// in its display order; the others, newest first.
export async function loadQuestionSummaries({
  subjectId,
  topicId,
  quizId,
}: QuestionSummaryFilter) {
  const rows = await sql<QuestionSummaryRow[]>`
    select
      q.id, q.type, coalesce(q.prompt, q.template) as statement,
      t.id as topic_id, t.number as topic_number, t.name as topic_name,
      s.id as subject_id, s.name as subject_name,
      (select count(*) from quiz_questions used where used.question_id = q.id)::int as quiz_count,
      exists (
        select 1 from quiz_attempt_answers answer where answer.question_id = q.id
      ) as answered
    from questions q
    join topics t on t.id = q.topic_id
    join subjects s on s.id = t.subject_id
    left join quiz_questions qq on qq.question_id = q.id and qq.quiz_id = ${quizId ?? null}::int
    where (${subjectId ?? null}::int is null or s.id = ${subjectId ?? null}::int)
      and (${topicId ?? null}::int is null or t.id = ${topicId ?? null}::int)
      and (${quizId ?? null}::int is null or qq.quiz_id is not null)
    order by qq.order_index, q.id desc
  `;

  return rows.map((row) => ({
    id: String(row.id),
    type: row.type,
    statement: row.statement,
    topicId: String(row.topic_id),
    topicNumber: row.topic_number,
    topicName: row.topic_name,
    subjectId: String(row.subject_id),
    subjectName: row.subject_name,
    quizCount: row.quiz_count,
    answered: row.answered,
  }));
}
