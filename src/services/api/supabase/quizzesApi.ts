import { FunctionsHttpError, FunctionsRelayError } from "@supabase/supabase-js";
import {
  quizDetailSchema,
  quizResultSchema,
  quizzesResponseSchema,
  type QuizAnswer,
  type QuizDetail,
  type QuizResult,
  type QuizSummary,
} from "@models/quizzes";
import { ApiError, INVALID_RESPONSE_MESSAGE } from "../errors";
import { getSupabase } from "../supabaseClient";
import { callFunction } from "./callFunction";
import { toApiError } from "./toApiError";

export const supabaseQuizzesApi = {
  getQuizzes(signal?: AbortSignal): Promise<QuizSummary[]> {
    return callFunction("list-quizzes", quizzesResponseSchema, { signal });
  },

  getQuiz(id: string, signal?: AbortSignal): Promise<QuizDetail> {
    return callFunction("get-quiz", quizDetailSchema, { query: { id }, signal });
  },

  // Goes through the submit-quiz-attempt edge function, which validates the body with zod
  // before the database grades it (supabase/functions/submit-quiz-attempt).
  async submitQuizAttempt(id: string, answers: QuizAnswer[]): Promise<QuizResult> {
    const { data, error } = await getSupabase().functions.invoke("submit-quiz-attempt", {
      body: { quizId: id, answers },
    });

    // An error with a response carries the contract's { code, message }; one without never
    // reached the function (offline, CORS).
    if (error instanceof FunctionsHttpError || error instanceof FunctionsRelayError) {
      const response: Response = error.context;
      throw toApiError(response.status, await response.json().catch(() => null), true);
    }
    if (error) throw toApiError(0, null, true);

    const result = quizResultSchema.safeParse(data);
    if (!result.success) {
      throw new ApiError(200, "INVALID_RESPONSE", INVALID_RESPONSE_MESSAGE);
    }
    return result.data;
  },
};
