import type { AdminOption, AdminQuestionInput, AdminQuestionType } from "@models/admin";

export const QUESTION_TYPE_LABEL: Record<AdminQuestionType, string> = {
  multiple_choice: "Múltipla escolha",
  multiple_answer: "Múltiplas alternativas",
  single_choice: "Seleção única em lacunas",
  drag_and_drop: "Arrastar e soltar",
  essay: "Dissertativa",
  essay_blanks: "Dissertativa com lacunas",
};

export type BlankDraft = { key: string; options: AdminOption[]; referenceAnswer: string };

// The editor's form: every field of every type at once, so switching the type of a new question
// keeps what was already typed. toQuestionInput sends only the fields of the chosen type.
export type QuestionDraft = {
  type: AdminQuestionType;
  prompt: string;
  template: string;
  explanation: string;
  maxLength: string;
  referenceAnswer: string;
  options: AdminOption[];
  blanks: BlankDraft[];
  terms: string[];
  slots: { key: string; correctTerm: string }[];
};

export function emptyOptions(): AdminOption[] {
  return [
    { text: "", isCorrect: false },
    { text: "", isCorrect: false },
  ];
}

export function emptyBlank(key: string): BlankDraft {
  return { key, options: emptyOptions(), referenceAnswer: "" };
}

export const EMPTY_QUESTION_DRAFT: QuestionDraft = {
  type: "multiple_choice",
  prompt: "",
  template: "",
  explanation: "",
  maxLength: "500",
  referenceAnswer: "",
  options: emptyOptions(),
  blanks: [emptyBlank("b1")],
  terms: ["", ""],
  slots: [{ key: "s1", correctTerm: "" }],
};

export function toQuestionDraft(question: AdminQuestionInput): QuestionDraft {
  const draft = { ...EMPTY_QUESTION_DRAFT, type: question.type };

  switch (question.type) {
    case "multiple_choice":
    case "multiple_answer":
      return {
        ...draft,
        prompt: question.prompt,
        explanation: question.explanation,
        options: question.options,
      };
    case "single_choice":
      return {
        ...draft,
        template: question.template,
        explanation: question.explanation,
        blanks: question.blanks.map((blank) => ({ ...blank, referenceAnswer: "" })),
      };
    case "drag_and_drop":
      return {
        ...draft,
        template: question.template,
        explanation: question.explanation,
        terms: question.terms,
        slots: question.slots,
      };
    case "essay":
      return {
        ...draft,
        prompt: question.prompt,
        maxLength: String(question.maxLength),
        referenceAnswer: question.referenceAnswer,
      };
    case "essay_blanks":
      return {
        ...draft,
        prompt: question.prompt,
        template: question.template,
        blanks: question.blanks.map((blank) => ({ ...blank, options: emptyOptions() })),
      };
  }
}

export function toQuestionInput(draft: QuestionDraft): AdminQuestionInput {
  const { type, prompt, template, explanation } = draft;

  switch (type) {
    case "multiple_choice":
    case "multiple_answer":
      return { type, prompt, explanation, options: draft.options };
    case "single_choice":
      return {
        type,
        template,
        explanation,
        blanks: draft.blanks.map(({ key, options }) => ({ key, options })),
      };
    case "drag_and_drop":
      return { type, template, explanation, terms: draft.terms, slots: draft.slots };
    case "essay":
      return {
        type,
        prompt,
        maxLength: Number(draft.maxLength),
        referenceAnswer: draft.referenceAnswer,
      };
    case "essay_blanks":
      return {
        type,
        prompt,
        template,
        blanks: draft.blanks.map(({ key, referenceAnswer }) => ({ key, referenceAnswer })),
      };
  }
}
