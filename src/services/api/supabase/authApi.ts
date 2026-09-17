import { FunctionsHttpError } from "@supabase/supabase-js";
import { z } from "zod";
import { studentUserSchema, type AuthSession, type LoginCredentials } from "@models/auth";
import { ApiError, INVALID_RESPONSE_MESSAGE, NETWORK_ERROR_MESSAGE } from "../errors";
import { getSupabase } from "../supabaseClient";
import { callRpc } from "./callRpc";
import { toApiError } from "./toApiError";

const signInResponseSchema = z.object({
  accessToken: z.string().min(1),
  refreshToken: z.string().min(1),
});

export const supabaseAuthApi = {
  async login(credentials: LoginCredentials): Promise<AuthSession> {
    const supabase = getSupabase();
    const { data, error } = await supabase.functions.invoke("sign-in", { body: credentials });

    if (error) {
      if (error instanceof FunctionsHttpError) {
        const response: Response = error.context;
        throw toApiError(response.status, await response.json().catch(() => null), false);
      }
      throw new ApiError(0, "NETWORK_ERROR", NETWORK_ERROR_MESSAGE);
    }

    const tokens = signInResponseSchema.safeParse(data);
    if (!tokens.success) {
      throw new ApiError(200, "INVALID_RESPONSE", INVALID_RESPONSE_MESSAGE);
    }

    const { error: sessionError } = await supabase.auth.setSession({
      access_token: tokens.data.accessToken,
      refresh_token: tokens.data.refreshToken,
    });
    if (sessionError) throw toApiError(sessionError.status ?? 0, null, false);

    const user = await callRpc("get_current_student", studentUserSchema);
    return { token: tokens.data.accessToken, user };
  },

  async logout(): Promise<void> {
    await getSupabase().auth.signOut();
  },
};
