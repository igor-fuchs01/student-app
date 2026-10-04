import {
  exercisesResponseSchema,
  quizDetailSchema,
  quizResultSchema,
  quizzesResponseSchema,
  type ExerciseFilters,
  type ExerciseSummary,
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

  getExercises({ topicId }: ExerciseFilters, signal?: AbortSignal): Promise<ExerciseSummary[]> {
    const query: Record<string, string> = {};
    if (topicId) query.topicId = topicId;
    return callFunction("list-exercises", exercisesResponseSchema, { query, signal });
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
