import {
  quizzesResponseSchema,
  quizDetailSchema,
  quizResultSchema,
  type QuizSummary,
  type QuizDetail,
  type QuizAnswer,
  type QuizResult,
} from "@models/quizzes";
import { USE_MOCKS } from "./config";
import { API_ENDPOINTS } from "./endpoints";
import { httpClient } from "./httpClient";
import { supabaseQuizzesApi } from "./supabase/quizzesApi";

const mockQuizzesApi = {
  getQuizzes(signal?: AbortSignal): Promise<QuizSummary[]> {
    return httpClient.get(API_ENDPOINTS.quizzes.list, quizzesResponseSchema, { signal });
  },

  getQuiz(id: string, signal?: AbortSignal): Promise<QuizDetail> {
    return httpClient.get(API_ENDPOINTS.quizzes.detail(id), quizDetailSchema, { signal });
  },

  submitQuizAttempt(id: string, answers: QuizAnswer[]): Promise<QuizResult> {
    return httpClient.post(API_ENDPOINTS.quizzes.submitAttempt(id), quizResultSchema, {
      answers,
    });
  },
};

export const quizzesApi = USE_MOCKS ? mockQuizzesApi : supabaseQuizzesApi;
