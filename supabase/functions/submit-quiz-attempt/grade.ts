import { ApiError } from "../_shared/http.ts";
import type { QuizQuestion } from "../_shared/questions.ts";

export type Answer = {
  questionId: string;
  optionId?: string;
  optionIds?: string[];
  text?: string;
  blankAnswers?: Record<string, string>;
  slotAnswers?: Record<string, string>;
};

export type ReviewStatus = "correct" | "incorrect" | "pending_review";

// One answered question, in the rows it is stored as.
export type GradedAnswer = {
  question: QuizQuestion;
  status: ReviewStatus;
  selectedOptionId: number | null; // multiple_choice
  essayText: string | null; // essay
  optionIds: number[]; // multiple_answer
  blanks: { blankId: number; blankKey: string; selectedOptionId: number | null; text: string | null }[];
  slots: { slotId: number; termId: number }[];
};

// The only rejection the grading gives back: a 400 that never says which answer was refused,
// whatever the reason (an id from another question or quiz, an essay past its limit, a repeated
// question). The zod schema of the body answers the same.
export const invalidAnswers = () => new ApiError(400, "VALIDATION_ERROR", "Respostas inválidas.");

// Same rule as src/features/quizzes/normalizeAnswerText.ts.
export const normalizeAnswerText = (text: string) => text.trim().toLowerCase().replace(/\s+/g, " ");

function emptyGrade(question: QuizQuestion): GradedAnswer {
  return {
    question,
    status: "incorrect",
    selectedOptionId: null,
    essayText: null,
    optionIds: [],
    blanks: [],
    slots: [],
  };
}

// Grades one answer against its question. Returns null when the question was left blank or
// partially filled: no row is stored and it counts as unanswered.
export function gradeAnswer(question: QuizQuestion, answer: Answer): GradedAnswer | null {
  const graded = emptyGrade(question);

  switch (question.type) {
    case "multiple_choice": {
      if (!answer.optionId) return null;
      const option = question.options.find((candidate) => candidate.id === Number(answer.optionId));
      if (!option) throw invalidAnswers();
      graded.selectedOptionId = option.id;
      graded.status = option.is_correct ? "correct" : "incorrect";
      return graded;
    }

    case "multiple_answer": {
      if (!answer.optionIds?.length) return null;
      const selected = [...new Set(answer.optionIds.map(Number))].sort((a, b) => a - b);
      if (selected.some((id) => !question.options.some((option) => option.id === id))) {
        throw invalidAnswers();
      }
      const expected = question.options
        .filter((option) => option.is_correct)
        .map((option) => option.id)
        .sort((a, b) => a - b);
      graded.optionIds = selected;
      graded.status = selected.join() === expected.join() ? "correct" : "incorrect";
      return graded;
    }

    case "single_choice": {
      const values = question.blanks.map((blank) => answer.blankAnswers?.[blank.blank_key] ?? "");
      if (values.some((value) => value === "")) return null;
      graded.blanks = question.blanks.map((blank, index) => {
        // blankAnswers also carries the free text of essay_blanks, so only here is it known to
        // hold an option id.
        const option = /^\d{1,9}$/.test(values[index])
          ? blank.options.find((candidate) => candidate.id === Number(values[index]))
          : undefined;
        if (!option) throw invalidAnswers();
        return { blankId: blank.id, blankKey: blank.blank_key, selectedOptionId: option.id, text: null };
      });
      graded.status = graded.blanks.every((value, index) =>
        question.blanks[index].options.some(
          (option) => option.id === value.selectedOptionId && option.is_correct,
        ),
      )
        ? "correct"
        : "incorrect";
      return graded;
    }

    case "drag_and_drop": {
      const values = question.slots.map((slot) => answer.slotAnswers?.[slot.slot_key] ?? "");
      if (values.some((value) => value === "")) return null;
      graded.slots = question.slots.map((slot, index) => {
        const term = question.terms.find((candidate) => candidate.id === Number(values[index]));
        if (!term) throw invalidAnswers();
        return { slotId: slot.id, termId: term.id };
      });
      graded.status = question.slots.every(
        (slot, index) => slot.correct_term_id === graded.slots[index].termId,
      )
        ? "correct"
        : "incorrect";
      return graded;
    }

    case "essay": {
      const text = answer.text ?? "";
      if (text.trim() === "") return null;
      if (text.length > question.maxLength!) throw invalidAnswers();
      graded.essayText = text;
      graded.status =
        normalizeAnswerText(text) === normalizeAnswerText(question.referenceAnswer!)
          ? "correct"
          : "pending_review";
      return graded;
    }

    case "essay_blanks": {
      const values = question.blanks.map((blank) => answer.blankAnswers?.[blank.blank_key] ?? "");
      if (values.some((value) => value.trim() === "")) return null;
      graded.blanks = question.blanks.map((blank, index) => ({
        blankId: blank.id,
        blankKey: blank.blank_key,
        selectedOptionId: null,
        text: values[index],
      }));
      graded.status = question.blanks.every(
        (blank, index) =>
          normalizeAnswerText(values[index]) === normalizeAnswerText(blank.reference_answer!),
      )
        ? "correct"
        : "pending_review";
      return graded;
    }
  }
}
