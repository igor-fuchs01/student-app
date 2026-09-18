import {
  quizDetailSchema,
  quizResultSchema,
  quizzesResponseSchema,
  type QuizAnswer,
  type QuizDetail,
  type QuizResult,
  type QuizSummary,
} from "@models/quizzes";
import { callRpc } from "./callRpc";

// Contract ids are strings; the database ids are integers. A non-numeric id becomes null and the
// function answers 404, like an unknown quiz.
export const supabaseQuizzesApi = {
  getQuizzes(signal?: AbortSignal): Promise<QuizSummary[]> {
    return callRpc("list_quizzes", quizzesResponseSchema, { signal });
  },

  getQuiz(id: string, signal?: AbortSignal): Promise<QuizDetail> {
    return callRpc("get_quiz", quizDetailSchema, { args: { p_quiz_id: Number(id) }, signal });
  },

  submitQuizAttempt(id: string, answers: QuizAnswer[]): Promise<QuizResult> {
    return callRpc("submit_quiz_attempt", quizResultSchema, {
      args: { p_quiz_id: Number(id), p_answers: answers },
    });
  },
};
