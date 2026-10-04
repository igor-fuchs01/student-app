import { isAuthRetryableFetchError } from "@supabase/supabase-js";
import { studentUserSchema, type AuthSession, type LoginCredentials } from "@models/auth";
import {
  ApiError,
  CAPTCHA_FAILED_MESSAGE,
  INVALID_CREDENTIALS_MESSAGE,
  NETWORK_ERROR_MESSAGE,
} from "../errors";
import { getSupabase } from "../supabaseClient";
import { callFunction } from "./callFunction";

// Supabase Auth needs an e-mail, so the access code the institution hands out is stored as
// <code>@alunos.student-app.invalid: a reserved domain that never receives mail.
const ACCESS_CODE_EMAIL_DOMAIN = "alunos.student-app.invalid";

export const supabaseAuthApi = {
  async login(
    { accessCode, password }: LoginCredentials,
    captchaToken?: string,
  ): Promise<AuthSession> {
    const { data, error } = await getSupabase().auth.signInWithPassword({
      email: `${accessCode}@${ACCESS_CODE_EMAIL_DOMAIN}`,
      password,
      options: { captchaToken },
    });

    if (error) {
      if (isAuthRetryableFetchError(error)) {
        throw new ApiError(0, "NETWORK_ERROR", NETWORK_ERROR_MESSAGE);
      }
      // Turnstile token missing, expired or already used: the credentials were not even checked.
      if (error.code === "captcha_failed") {
        throw new ApiError(error.status ?? 400, "CAPTCHA_FAILED", CAPTCHA_FAILED_MESSAGE);
      }
      // Same answer for an unknown access code and a wrong password, so accounts can't be probed.
      throw new ApiError(401, "INVALID_CREDENTIALS", INVALID_CREDENTIALS_MESSAGE);
    }

    const user = await callFunction("get-current-student", studentUserSchema);
    return { token: data.session.access_token, user };
  },

  async logout(): Promise<void> {
    await getSupabase().auth.signOut();
  },
};
