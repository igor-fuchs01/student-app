import type { Question, QuizAnswer } from "@models/quizzes";

export function isQuestionAnswered(question: Question, answer: QuizAnswer | undefined): boolean {
  if (!answer) return false;

  switch (question.type) {
    case "multiple_choice":
      return Boolean(answer.optionId);
    case "multiple_answer":
      return Boolean(answer.optionIds && answer.optionIds.length > 0);
    case "single_choice":
      return question.blanks.every((blank) => Boolean(answer.blankAnswers?.[blank.id]));
    case "drag_and_drop":
      return question.slots.every((slot) => Boolean(answer.slotAnswers?.[slot.id]));
    case "essay":
      return Boolean(answer.text?.trim());
    case "essay_blanks":
      return question.blanks.every((blank) => Boolean(answer.blankAnswers?.[blank.id]?.trim()));
  }
}
