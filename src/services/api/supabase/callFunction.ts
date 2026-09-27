import { FunctionsHttpError, FunctionsRelayError } from "@supabase/supabase-js";
import type { ZodType } from "zod";
import { ApiError, INVALID_RESPONSE_MESSAGE } from "../errors";
import { getSupabase } from "../supabaseClient";
import { toApiError } from "./toApiError";

type FunctionOptions = {
  method?: "GET" | "POST";
  query?: Record<string, string>;
  body?: Record<string, unknown>;
  signal?: AbortSignal;
};

// Calls one of the edge functions in supabase/functions/, which answer with the contract's JSON.
export async function callFunction<T>(
  functionName: string,
  schema: ZodType<T>,
  { method = "GET", query, body, signal }: FunctionOptions = {},
): Promise<T> {
  const path = query ? `${functionName}?${new URLSearchParams(query)}` : functionName;
  const { data, error } = await getSupabase().functions.invoke(path, { method, body, signal });

  if (signal?.aborted) throw signal.reason;

  // An error with a response carries the contract's { code, message }; one without never
  // reached the function (offline, CORS).
  if (error instanceof FunctionsHttpError || error instanceof FunctionsRelayError) {
    const response: Response = error.context;
    throw toApiError(response.status, await response.json().catch(() => null), true);
  }
  if (error) throw toApiError(0, null, true);

  const result = schema.safeParse(data);
  if (!result.success) {
    throw new ApiError(200, "INVALID_RESPONSE", INVALID_RESPONSE_MESSAGE);
  }
  return result.data;
}
