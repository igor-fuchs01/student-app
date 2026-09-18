import { isAuthRetryableFetchError } from "@supabase/supabase-js";
import { studentUserSchema, type AuthSession, type LoginCredentials } from "@models/auth";
import { ApiError, INVALID_CREDENTIALS_MESSAGE, NETWORK_ERROR_MESSAGE } from "../errors";
import { getSupabase } from "../supabaseClient";
import { callRpc } from "./callRpc";

export const supabaseAuthApi = {
  async login({ email, password }: LoginCredentials): Promise<AuthSession> {
    const { data, error } = await getSupabase().auth.signInWithPassword({ email, password });

    if (error) {
      if (isAuthRetryableFetchError(error)) {
        throw new ApiError(0, "NETWORK_ERROR", NETWORK_ERROR_MESSAGE);
      }
      // Same answer for an unknown e-mail and a wrong password, so accounts can't be probed.
      throw new ApiError(401, "INVALID_CREDENTIALS", INVALID_CREDENTIALS_MESSAGE);
    }

    const user = await callRpc("get_current_student", studentUserSchema);
    return { token: data.session.access_token, user };
  },

  async logout(): Promise<void> {
    await getSupabase().auth.signOut();
  },
};
