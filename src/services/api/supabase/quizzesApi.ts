import {
  quizDetailSchema,
  quizResultSchema,
  quizzesResponseSchema,
  type QuizAnswer,
  type QuizDetail,
  type QuizResult,
  type QuizSummary,
} from "@models/quizzes";
import { callFunction } from "./callFunction";

export const supabaseQuizzesApi = {
  getQuizzes(signal?: AbortSignal): Promise<QuizSummary[]> {
    return callFunction("list-quizzes", quizzesResponseSchema, { signal });
  },

  getQuiz(id: string, signal?: AbortSignal): Promise<QuizDetail> {
    return callFunction("get-quiz", quizDetailSchema, { query: { id }, signal });
  },

  submitQuizAttempt(id: string, answers: QuizAnswer[]): Promise<QuizResult> {
    return callFunction("submit-quiz-attempt", quizResultSchema, {
      method: "POST",
      body: { quizId: id, answers },
    });
  },
};
