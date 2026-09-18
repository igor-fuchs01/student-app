import {
  ApiError,
  apiErrorBodySchema,
  NETWORK_ERROR_MESSAGE,
  SESSION_EXPIRED_MESSAGE,
  UNKNOWN_ERROR_MESSAGE,
} from "../errors";
import { notifyUnauthorized } from "../httpClient";
import { getSupabase } from "../supabaseClient";

// Supabase functions reply with the same { code, message } body as the contract; errors raised by
// Supabase itself (expired JWT, missing permission) don't, so they fall back to generic messages.
export function toApiError(status: number, body: unknown, authenticated: boolean): ApiError {
  if (status === 0) {
    return new ApiError(0, "NETWORK_ERROR", NETWORK_ERROR_MESSAGE);
  }

  const unauthorized = status === 401 || status === 403;
  if (unauthorized && authenticated) {
    notifyUnauthorized();
    void getSupabase().auth.signOut({ scope: "local" });
  }

  const errorBody = apiErrorBodySchema.safeParse(body);
  if (errorBody.success && errorBody.data.code !== "UNKNOWN_ERROR") {
    return new ApiError(status, errorBody.data.code, errorBody.data.message);
  }
  if (unauthorized) {
    return new ApiError(status, "UNAUTHORIZED", SESSION_EXPIRED_MESSAGE);
  }
  return new ApiError(status, "UNKNOWN_ERROR", UNKNOWN_ERROR_MESSAGE);
}
