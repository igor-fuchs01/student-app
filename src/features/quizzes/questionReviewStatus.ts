import type { BadgeTone } from "@components/ui/Badge";
import type { Question, QuizAnswer, QuizResult } from "@models/quizzes";
import { isQuestionAnswered } from "@features/quizzes/isQuestionAnswered";

export type QuestionReviewStatus = "correct" | "incorrect" | "unanswered" | "self_review";

export const QUESTION_STATUS_LABEL: Record<QuestionReviewStatus, string> = {
  correct: "Correta",
  incorrect: "Incorreta",
  unanswered: "Não respondida",
  self_review: "Autoavaliação",
};

export const QUESTION_STATUS_TONE: Record<QuestionReviewStatus, BadgeTone> = {
  correct: "accent",
  incorrect: "danger",
  unanswered: "danger",
  self_review: "accent2",
};

const LEGEND_ORDER: QuestionReviewStatus[] = ["correct", "incorrect", "self_review", "unanswered"];

export const QUESTION_STATUS_LEGEND = LEGEND_ORDER.map((status) => ({
  label: QUESTION_STATUS_LABEL[status],
  tone: status,
}));

export function getQuestionReviewStatus(
  question: Question,
  answer: QuizAnswer | undefined,
  result: QuizResult,
): QuestionReviewStatus {
  const reviewItem = result.reviewItems.find((item) => item.questionId === question.id);
  if (reviewItem) return reviewItem.status;
  return isQuestionAnswered(question, answer) ? "correct" : "unanswered";
}

export function getQuestionReviewStatuses(
  questions: Question[],
  answers: QuizAnswer[],
  result: QuizResult,
): QuestionReviewStatus[] {
  const answerByQuestionId = new Map(answers.map((answer) => [answer.questionId, answer]));
  return questions.map((question) =>
    getQuestionReviewStatus(question, answerByQuestionId.get(question.id), result),
  );
}
