import { isAuthRetryableFetchError } from "@supabase/supabase-js";
import type { ZodType } from "zod";
import {
  adminContentSchema,
  adminQuestionSchema,
  adminQuestionsSchema,
  adminQuizDetailSchema,
  adminQuizzesSchema,
  adminSavedSchema,
  adminUserSchema,
  type AdminQuestion,
  type AdminQuestionFilters,
  type AdminQuestionSave,
  type AdminQuestionSummary,
  type AdminQuizDetail,
  type AdminQuizInput,
  type AdminQuizSummary,
  type AdminSaved,
  type AdminSubject,
  type AdminSubjectInput,
  type AdminSubtopicInput,
  type AdminTopicInput,
  type AdminUser,
} from "@models/admin";
import type { LoginCredentials } from "@models/auth";
import {
  ApiError,
  CAPTCHA_FAILED_MESSAGE,
  INVALID_CREDENTIALS_MESSAGE,
  NETWORK_ERROR_MESSAGE,
} from "./errors";
import { callFunction } from "./supabase/callFunction";
import { getSupabase } from "./supabaseClient";

// An admin account is stored in Supabase Auth as <code>@admin.student-app.invalid. The student
// login uses another domain, so neither screen can sign in an account of the other kind.
const ADMIN_EMAIL_DOMAIN = "admin.student-app.invalid";

type AdminCallOptions = {
  query?: Record<string, string>;
  body?: Record<string, unknown>;
  signal?: AbortSignal;
};

let sessionLostHandler: (() => void) | null = null;

// The admin route guard registers here to check the session again when a call is refused.
export function onAdminSessionLost(handler: (() => void) | null): void {
  sessionLostHandler = handler;
}

// The admin area only exists on Supabase: there is no mock implementation. Every call is
// authorized again on the server, which is what actually protects the data.
async function call<T>(
  functionName: string,
  schema: ZodType<T>,
  { query, body, signal }: AdminCallOptions = {},
): Promise<T> {
  try {
    return await callFunction(functionName, schema, {
      method: body ? "POST" : "GET",
      query,
      body,
      signal,
      studentSession: false,
    });
  } catch (error) {
    if (error instanceof ApiError && (error.status === 401 || error.status === 403)) {
      sessionLostHandler?.();
    }
    throw error;
  }
}

function getCurrentAdmin(signal?: AbortSignal): Promise<AdminUser> {
  return callFunction("admin-get-current", adminUserSchema, { signal, studentSession: false });
}

export const adminApi = {
  async login(
    { accessCode, password }: LoginCredentials,
    captchaToken?: string,
  ): Promise<AdminUser> {
    const { error } = await getSupabase().auth.signInWithPassword({
      email: `${accessCode}@${ADMIN_EMAIL_DOMAIN}`,
      password,
      options: { captchaToken },
    });

    if (error) {
      if (isAuthRetryableFetchError(error)) {
        throw new ApiError(0, "NETWORK_ERROR", NETWORK_ERROR_MESSAGE);
      }
      if (error.code === "captcha_failed") {
        throw new ApiError(error.status ?? 400, "CAPTCHA_FAILED", CAPTCHA_FAILED_MESSAGE);
      }
      throw new ApiError(401, "INVALID_CREDENTIALS", INVALID_CREDENTIALS_MESSAGE);
    }

    try {
      return await getCurrentAdmin();
    } catch (err) {
      await getSupabase().auth.signOut();
      // Same answer for a wrong password and for an account that is not an admin.
      if (err instanceof ApiError && (err.status === 401 || err.status === 403)) {
        throw new ApiError(401, "INVALID_CREDENTIALS", INVALID_CREDENTIALS_MESSAGE);
      }
      throw err;
    }
  },

  async logout(): Promise<void> {
    await getSupabase().auth.signOut();
  },

  getCurrentAdmin,

  getContent(signal?: AbortSignal): Promise<AdminSubject[]> {
    return call("admin-get-content", adminContentSchema, { signal });
  },

  saveSubject(subject: AdminSubjectInput): Promise<AdminSaved> {
    return call("admin-save-subject", adminSavedSchema, { body: subject });
  },

  deleteSubject(id: string): Promise<AdminSaved> {
    return call("admin-delete-subject", adminSavedSchema, { body: { id } });
  },

  saveTopic(topic: AdminTopicInput): Promise<AdminSaved> {
    return call("admin-save-topic", adminSavedSchema, { body: topic });
  },

  deleteTopic(id: string): Promise<AdminSaved> {
    return call("admin-delete-topic", adminSavedSchema, { body: { id } });
  },

  saveSubtopic(subtopic: AdminSubtopicInput): Promise<AdminSaved> {
    return call("admin-save-subtopic", adminSavedSchema, { body: subtopic });
  },

  deleteSubtopic(id: string): Promise<AdminSaved> {
    return call("admin-delete-subtopic", adminSavedSchema, { body: { id } });
  },

  getQuestions(
    filters: AdminQuestionFilters,
    signal?: AbortSignal,
  ): Promise<AdminQuestionSummary[]> {
    const query: Record<string, string> = {};
    if (filters.subjectId) query.subjectId = filters.subjectId;
    if (filters.topicId) query.topicId = filters.topicId;
    return call("admin-list-questions", adminQuestionsSchema, { query, signal });
  },

  getQuestion(id: string, signal?: AbortSignal): Promise<AdminQuestion> {
    return call("admin-get-question", adminQuestionSchema, { query: { id }, signal });
  },

  saveQuestion(question: AdminQuestionSave): Promise<AdminSaved> {
    return call("admin-save-question", adminSavedSchema, { body: question });
  },

  deleteQuestion(id: string): Promise<AdminSaved> {
    return call("admin-delete-question", adminSavedSchema, { body: { id } });
  },

  getQuizzes(signal?: AbortSignal): Promise<AdminQuizSummary[]> {
    return call("admin-list-quizzes", adminQuizzesSchema, { signal });
  },

  getQuiz(id: string, signal?: AbortSignal): Promise<AdminQuizDetail> {
    return call("admin-get-quiz", adminQuizDetailSchema, { query: { id }, signal });
  },

  saveQuiz(quiz: AdminQuizInput): Promise<AdminSaved> {
    return call("admin-save-quiz", adminSavedSchema, { body: quiz });
  },

  deleteQuiz(id: string): Promise<AdminSaved> {
    return call("admin-delete-quiz", adminSavedSchema, { body: { id } });
  },

  // The document is validated by the server, which reports every problem it finds.
  importQuiz(document: Record<string, unknown>): Promise<AdminSaved> {
    return call("admin-import-quiz", adminSavedSchema, { body: document });
  },
};
