import { loginCredentialsSchema, type AuthSession } from "@models/auth";
import { MOCK_DELAY_MS } from "../config";
import { API_ENDPOINTS } from "../endpoints";
import type { ApiErrorBody, ApiErrorCode } from "../errors";
import { buildMockDashboard } from "./dashboard";
import { findAccountById, findAccountByIdentifier, type MockAccount } from "./users";

type MockResult = {
  status: number;
  body?: unknown;
};

type MockRoute =
  | { authenticated: false; handle: (body: unknown) => MockResult }
  | { authenticated: true; handle: (body: unknown, account: MockAccount) => MockResult };

const TOKEN_PREFIX = "mock";

function createToken(accountId: string): string {
  return `${TOKEN_PREFIX}.${accountId}.${crypto.randomUUID()}`;
}

function resolveAccount(authorization: string | null): MockAccount | undefined {
  const token = authorization?.match(/^Bearer (.+)$/)?.[1];
  const [prefix, accountId] = token?.split(".") ?? [];
  if (prefix !== TOKEN_PREFIX || !accountId) return undefined;
  return findAccountById(accountId);
}

function errorResult(status: number, code: ApiErrorCode, message: string): MockResult {
  const body: ApiErrorBody = { code, message };
  return { status, body };
}

const routes: Record<string, MockRoute> = {
  [`POST ${API_ENDPOINTS.auth.login}`]: {
    authenticated: false,
    handle(body) {
      const credentials = loginCredentialsSchema.safeParse(body);
      if (!credentials.success) {
        return errorResult(400, "VALIDATION_ERROR", "Informe matrícula/e-mail e senha.");
      }

      const { identifier, password } = credentials.data;
      const account = findAccountByIdentifier(identifier);
      console.log(account, password)
      if (!account || account.password !== password) {
        return errorResult(401, "INVALID_CREDENTIALS", "Matrícula/e-mail ou senha inválidos.");
      }

      const session: AuthSession = { token: createToken(account.user.id), user: account.user };
      return { status: 200, body: session };
    },
  },

  [`POST ${API_ENDPOINTS.auth.logout}`]: {
    authenticated: true,
    handle: () => ({ status: 204 }),
  },

  [`GET ${API_ENDPOINTS.dashboard}`]: {
    authenticated: true,
    handle: () => ({ status: 200, body: buildMockDashboard() }),
  },
};

function delay(ms: number, signal?: AbortSignal | null): Promise<void> {
  return new Promise((resolve, reject) => {
    if (signal?.aborted) {
      reject(signal.reason);
      return;
    }

    const timer = setTimeout(resolve, ms);
    signal?.addEventListener(
      "abort",
      () => {
        clearTimeout(timer);
        reject(signal.reason);
      },
      { once: true },
    );
  });
}

function parseJson(body: RequestInit["body"]): unknown {
  if (typeof body !== "string") return undefined;
  try {
    return JSON.parse(body);
  } catch {
    return undefined;
  }
}

function toResponse({ status, body }: MockResult): Response {
  if (body === undefined) return new Response(null, { status });
  return new Response(JSON.stringify(body), {
    status,
    headers: { "Content-Type": "application/json" },
  });
}

export async function mockFetch(input: RequestInfo | URL, init: RequestInit = {}): Promise<Response> {
  await delay(MOCK_DELAY_MS, init.signal);

  const url = new URL(input instanceof Request ? input.url : String(input), window.location.origin);
  const method = (init.method ?? "GET").toUpperCase();
  const route = routes[`${method} ${url.pathname}`];

  if (!route) {
    return toResponse(errorResult(404, "NOT_FOUND", "Recurso não encontrado."));
  }

  const body = parseJson(init.body);

  if (!route.authenticated) {
    return toResponse(route.handle(body));
  }

  const account = resolveAccount(new Headers(init.headers).get("Authorization"));
  if (!account) {
    return toResponse(errorResult(401, "UNAUTHORIZED", "Sessão expirada. Faça login novamente."));
  }

  return toResponse(route.handle(body, account));
}
