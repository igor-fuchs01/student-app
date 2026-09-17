import type { ZodType } from "zod";
import { tokenStorage } from "@services/storage/tokenStorage";
import { MOCK_API_BASE_URL } from "./config";
import {
  ApiError,
  apiErrorBodySchema,
  INVALID_RESPONSE_MESSAGE,
  NETWORK_ERROR_MESSAGE,
  UNKNOWN_ERROR_MESSAGE,
} from "./errors";

type HttpMethod = "GET" | "POST";

type RequestOptions = {
  signal?: AbortSignal;
  authenticated?: boolean;
};

let unauthorizedHandler: (() => void) | null = null;

export function onUnauthorized(handler: () => void): void {
  unauthorizedHandler = handler;
}

export function notifyUnauthorized(): void {
  tokenStorage.clearSession();
  unauthorizedHandler?.();
}

async function parseBody(response: Response): Promise<unknown> {
  const text = await response.text();
  if (!text) return undefined;

  try {
    return JSON.parse(text);
  } catch {
    return undefined;
  }
}

async function request<T>(
  method: HttpMethod,
  path: string,
  schema: ZodType<T>,
  body: unknown,
  { signal, authenticated = true }: RequestOptions = {},
): Promise<T> {
  const headers = new Headers({ Accept: "application/json" });
  if (body !== undefined) headers.set("Content-Type", "application/json");

  const token = authenticated ? tokenStorage.getToken() : null;
  if (token) headers.set("Authorization", `Bearer ${token}`);

  let response: Response;
  try {
    // Only mock mode goes through here: MSW answers every request under this prefix.
    response = await fetch(`${MOCK_API_BASE_URL}${path}`, {
      method,
      headers,
      signal,
      body: body === undefined ? undefined : JSON.stringify(body),
    });
  } catch (error) {
    if (signal?.aborted) throw error;
    throw new ApiError(0, "NETWORK_ERROR", NETWORK_ERROR_MESSAGE);
  }

  const payload = await parseBody(response);

  if (!response.ok) {
    if (response.status === 401 && authenticated) {
      notifyUnauthorized();
    }

    const errorBody = apiErrorBodySchema.safeParse(payload);
    if (errorBody.success) {
      throw new ApiError(response.status, errorBody.data.code, errorBody.data.message);
    }
    throw new ApiError(response.status, "UNKNOWN_ERROR", UNKNOWN_ERROR_MESSAGE);
  }

  const result = schema.safeParse(payload);
  if (!result.success) {
    throw new ApiError(response.status, "INVALID_RESPONSE", INVALID_RESPONSE_MESSAGE);
  }

  return result.data;
}

export const httpClient = {
  get<T>(path: string, schema: ZodType<T>, options?: RequestOptions): Promise<T> {
    return request("GET", path, schema, undefined, options);
  },

  post<T>(path: string, schema: ZodType<T>, body?: unknown, options?: RequestOptions): Promise<T> {
    return request("POST", path, schema, body, options);
  },
};
