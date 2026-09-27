import { sql } from "./db.ts";

export type QuestionType =
  | "multiple_choice"
  | "multiple_answer"
  | "single_choice"
  | "drag_and_drop"
  | "essay"
  | "essay_blanks";

type QuestionRow = {
  id: number;
  type: QuestionType;
  subject_id: number;
  subject_name: string;
  prompt: string | null;
  template: string | null;
  explanation: string | null;
  max_length: number | null;
  reference_answer: string | null;
};

type OptionRow = { id: number; question_id: number; text: string; is_correct: boolean };
type BlankRow = { id: number; question_id: number; blank_key: string; reference_answer: string | null };
type BlankOptionRow = { id: number; blank_id: number; text: string; is_correct: boolean };
type TermRow = { id: number; question_id: number; text: string };
type SlotRow = { id: number; question_id: number; slot_key: string; correct_term_id: number };

export type QuizQuestion = {
  id: number;
  type: QuestionType;
  subjectId: number;
  subjectName: string;
  prompt: string | null;
  template: string | null;
  explanation: string | null;
  maxLength: number | null;
  referenceAnswer: string | null;
  options: OptionRow[];
  blanks: (BlankRow & { options: BlankOptionRow[] })[];
  terms: TermRow[];
  slots: SlotRow[];
};

// Every question of a quiz, in display order, with its answer keys. Each child table is read in
// one query filtered by the quiz and grouped here, instead of one query per question.
export async function loadQuizQuestions(quizId: number): Promise<QuizQuestion[]> {
  const [questions, options, blanks, blankOptions, terms, slots] = await Promise.all([
    sql<QuestionRow[]>`
      select
        q.id, q.type, s.id as subject_id, s.name as subject_name,
        q.prompt, q.template, q.explanation, q.max_length, q.reference_answer
      from quiz_questions qq
      join questions q on q.id = qq.question_id
      join topics t on t.id = q.topic_id
      join subjects s on s.id = t.subject_id
      where qq.quiz_id = ${quizId}
      order by qq.order_index
    `,
    sql<OptionRow[]>`
      select o.id, o.question_id, o.text, o.is_correct
      from question_options o
      join quiz_questions qq on qq.question_id = o.question_id
      where qq.quiz_id = ${quizId}
      order by o.order_index
    `,
    sql<BlankRow[]>`
      select b.id, b.question_id, b.blank_key, b.reference_answer
      from question_blanks b
      join quiz_questions qq on qq.question_id = b.question_id
      where qq.quiz_id = ${quizId}
      order by b.order_index
    `,
    sql<BlankOptionRow[]>`
      select bo.id, bo.blank_id, bo.text, bo.is_correct
      from question_blank_options bo
      join question_blanks b on b.id = bo.blank_id
      join quiz_questions qq on qq.question_id = b.question_id
      where qq.quiz_id = ${quizId}
      order by bo.order_index
    `,
    sql<TermRow[]>`
      select term.id, term.question_id, term.text
      from question_terms term
      join quiz_questions qq on qq.question_id = term.question_id
      where qq.quiz_id = ${quizId}
      order by term.order_index
    `,
    sql<SlotRow[]>`
      select slot.id, slot.question_id, slot.slot_key, slot.correct_term_id
      from question_slots slot
      join quiz_questions qq on qq.question_id = slot.question_id
      where qq.quiz_id = ${quizId}
      order by slot.order_index
    `,
  ]);

  return questions.map((question) => ({
    id: question.id,
    type: question.type,
    subjectId: question.subject_id,
    subjectName: question.subject_name,
    prompt: question.prompt,
    template: question.template,
    explanation: question.explanation,
    maxLength: question.max_length,
    referenceAnswer: question.reference_answer,
    options: options.filter((option) => option.question_id === question.id),
    blanks: blanks
      .filter((blank) => blank.question_id === question.id)
      .map((blank) => ({
        ...blank,
        options: blankOptions.filter((option) => option.blank_id === blank.id),
      })),
    terms: terms.filter((term) => term.question_id === question.id),
    slots: slots.filter((slot) => slot.question_id === question.id),
  }));
}

const toOption = (option: { id: number; text: string }) => ({
  id: String(option.id),
  text: option.text,
});

const correctOptionId = (options: { id: number; is_correct: boolean }[]) =>
  String(options.find((option) => option.is_correct)?.id);

// Question (docs/04-contratos-de-api.md §3.12), in the shape of its type.
export function toQuestionDto(question: QuizQuestion) {
  const base = { type: question.type, id: String(question.id), subjectName: question.subjectName };

  switch (question.type) {
    case "multiple_choice":
      return {
        ...base,
        prompt: question.prompt,
        options: question.options.map(toOption),
        correctOptionId: correctOptionId(question.options),
        explanation: question.explanation,
      };
    case "multiple_answer":
      return {
        ...base,
        prompt: question.prompt,
        options: question.options.map(toOption),
        correctOptionIds: question.options
          .filter((option) => option.is_correct)
          .map((option) => String(option.id)),
        explanation: question.explanation,
      };
    case "single_choice":
      return {
        ...base,
        template: question.template,
        blanks: question.blanks.map((blank) => ({
          id: blank.blank_key,
          options: blank.options.map(toOption),
          correctOptionId: correctOptionId(blank.options),
        })),
        explanation: question.explanation,
      };
    case "drag_and_drop":
      return {
        ...base,
        template: question.template,
        terms: question.terms.map(toOption),
        slots: question.slots.map((slot) => ({
          id: slot.slot_key,
          correctTermId: String(slot.correct_term_id),
        })),
        explanation: question.explanation,
      };
    case "essay":
      return {
        ...base,
        prompt: question.prompt,
        maxLength: question.maxLength,
        referenceAnswer: question.referenceAnswer,
      };
    case "essay_blanks":
      return {
        ...base,
        prompt: question.prompt,
        template: question.template,
        blanks: question.blanks.map((blank) => ({
          id: blank.blank_key,
          referenceAnswer: blank.reference_answer,
        })),
      };
  }
}
