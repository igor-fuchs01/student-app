import { useOutletContext } from "react-router-dom";
import type { QuizAnswer, QuizDetail } from "@models/quizzes";

export type QuizAttemptContextValue = {
  quiz: QuizDetail;
  currentIndex: number;
  setCurrentIndex: (index: number) => void;
  answers: Record<string, QuizAnswer>;
  setAnswer: (questionId: string, patch: Omit<QuizAnswer, "questionId">) => void;
  markedForReview: Set<string>;
  toggleMarkedForReview: (questionId: string) => void;
  timeLimitEnabled: boolean;
  remainingSeconds: number;
  elapsedSeconds: number;
  isTimeUp: boolean;
  showTimer: boolean;
  toggleShowTimer: () => void;
  isSubmitting: boolean;
  submitError: string | null;
  submit: () => void;
};

export function useQuizAttemptContext(): QuizAttemptContextValue {
  return useOutletContext<QuizAttemptContextValue>();
}
