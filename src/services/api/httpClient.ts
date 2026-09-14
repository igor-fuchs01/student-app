import type { ZodType } from "zod";
import { tokenStorage } from "@services/storage/tokenStorage";
import { API_BASE_URL, USE_MOCKS } from "./config";
import { ApiError, apiErrorBodySchema } from "./errors";

type HttpMethod = "GET" | "POST";

type RequestOptions = {
  signal?: AbortSignal;
  authenticated?: boolean;
};

const transport: typeof fetch =
  import.meta.env.VITE_USE_MOCKS === "true"
    ? (input, init) => import("./mocks/mockServer").then(({ mockFetch }) => mockFetch(input, init))
    : fetch.bind(globalThis);
const baseUrl = USE_MOCKS ? "" : API_BASE_URL;

let unauthorizedHandler: (() => void) | null = null;

export function onUnauthorized(handler: () => void): void {
  unauthorizedHandler = handler;
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
    response = await transport(`${baseUrl}${path}`, {
      method,
      headers,
      signal,
      body: body === undefined ? undefined : JSON.stringify(body),
    });
  } catch (error) {
    if (signal?.aborted) throw error;
    throw new ApiError(
      0,
      "NETWORK_ERROR",
      "Não foi possível conectar ao servidor. Verifique sua conexão.",
    );
  }

  const payload = await parseBody(response);

  if (!response.ok) {
    if (response.status === 401 && authenticated) {
      tokenStorage.clearSession();
      unauthorizedHandler?.();
    }

    const errorBody = apiErrorBodySchema.safeParse(payload);
    if (errorBody.success) {
      throw new ApiError(response.status, errorBody.data.code, errorBody.data.message);
    }
    throw new ApiError(
      response.status,
      "UNKNOWN_ERROR",
      "Ocorreu um erro inesperado. Tente novamente.",
    );
  }

  const result = schema.safeParse(payload);
  if (!result.success) {
    throw new ApiError(
      response.status,
      "INVALID_RESPONSE",
      "Recebemos uma resposta inválida do servidor. Tente novamente.",
    );
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
