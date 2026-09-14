import type { Question, QuizAnswer, QuizResult } from "@models/quizzes";
import { isQuestionAnswered } from "../../isQuestionAnswered";

export type QuestionReviewStatus = "correct" | "incorrect" | "unanswered" | "self_review";

export const QUESTION_STATUS_LABEL: Record<QuestionReviewStatus, string> = {
  correct: "Correta",
  incorrect: "Incorreta",
  unanswered: "Não respondida",
  self_review: "Autoavaliação",
};

export const QUESTION_STATUS_TONE: Record<QuestionReviewStatus, "accent" | "accent2" | "danger"> = {
  correct: "accent",
  incorrect: "danger",
  unanswered: "danger",
  self_review: "accent2",
};

export function getQuestionReviewStatus(
  question: Question,
  answer: QuizAnswer | undefined,
  result: QuizResult,
): QuestionReviewStatus {
  const reviewItem = result.reviewItems.find((item) => item.questionId === question.id);
  if (reviewItem) return reviewItem.status;
  return isQuestionAnswered(question, answer) ? "correct" : "unanswered";
}
