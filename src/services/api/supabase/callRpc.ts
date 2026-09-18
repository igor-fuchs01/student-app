import type { ZodType } from "zod";
import { ApiError, INVALID_RESPONSE_MESSAGE } from "../errors";
import { getSupabase } from "../supabaseClient";
import { toApiError } from "./toApiError";

type RpcOptions = {
  args?: Record<string, unknown>;
  signal?: AbortSignal;
};

export async function callRpc<T>(
  functionName: string,
  schema: ZodType<T>,
  { args, signal }: RpcOptions = {},
): Promise<T> {
  const request = getSupabase().rpc(functionName, args);
  const { data, error, status } = await (signal ? request.abortSignal(signal) : request);

  if (signal?.aborted) throw signal.reason;
  if (error) throw toApiError(status, error, true);

  const result = schema.safeParse(data);
  if (!result.success) {
    throw new ApiError(status, "INVALID_RESPONSE", INVALID_RESPONSE_MESSAGE);
  }
  return result.data;
}
