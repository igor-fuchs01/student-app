import { loginCredentialsSchema, type AuthSession } from "@models/auth";
import { submitQuizAttemptSchema } from "@models/quizzes";
import { MOCK_DELAY_MS } from "../config";
import { API_ENDPOINTS } from "../endpoints";
import type { ApiErrorBody, ApiErrorCode } from "../errors";
import { buildMockDashboard } from "./dashboard";
import { buildMockSubjects } from "./subjects";
import {
  buildMockQuizList,
  correctMockQuizAttempt,
  getMockQuizDetail,
  registerMockQuizAttempt,
} from "./quizzes";
import { buildMockRanking } from "./ranking";
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

  [`GET ${API_ENDPOINTS.subjects}`]: {
    authenticated: true,
    handle: () => ({ status: 200, body: buildMockSubjects() }),
  },

  [`GET ${API_ENDPOINTS.quizzes.list}`]: {
    authenticated: true,
    handle: (_body, account) => ({ status: 200, body: buildMockQuizList(account.user.id) }),
  },

  [`GET ${API_ENDPOINTS.ranking}`]: {
    authenticated: true,
    handle: (_body, account) => ({ status: 200, body: buildMockRanking(account.user) }),
  },
};

const QUIZ_DETAIL_PATTERN = /^\/quizzes\/([^/]+)$/;
const QUIZ_ATTEMPT_PATTERN = /^\/quizzes\/([^/]+)\/attempts$/;

function handleQuizDetail(id: string): MockResult {
  const quiz = getMockQuizDetail(id);
  if (!quiz) {
    return errorResult(404, "NOT_FOUND", "Simulado não encontrado.");
  }
  return { status: 200, body: quiz };
}

function handleQuizAttemptSubmit(id: string, body: unknown, studentId: string): MockResult {
  const payload = submitQuizAttemptSchema.safeParse(body);
  if (!payload.success) {
    return errorResult(400, "VALIDATION_ERROR", "Respostas inválidas.");
  }

  const result = correctMockQuizAttempt(id, payload.data.answers);
  if (!result) {
    return errorResult(404, "NOT_FOUND", "Simulado não encontrado.");
  }

  registerMockQuizAttempt(studentId, id);
  return { status: 200, body: result };
}

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

export async function mockFetch(
  input: RequestInfo | URL,
  init: RequestInit = {},
): Promise<Response> {
  await delay(MOCK_DELAY_MS, init.signal);

  const url = new URL(input instanceof Request ? input.url : String(input), window.location.origin);
  const method = (init.method ?? "GET").toUpperCase();
  const body = parseJson(init.body);

  const quizDetailMatch = method === "GET" ? url.pathname.match(QUIZ_DETAIL_PATTERN) : null;
  const quizAttemptMatch = method === "POST" ? url.pathname.match(QUIZ_ATTEMPT_PATTERN) : null;

  if (quizDetailMatch || quizAttemptMatch) {
    const account = resolveAccount(new Headers(init.headers).get("Authorization"));
    if (!account) {
      return toResponse(errorResult(401, "UNAUTHORIZED", "Sessão expirada. Faça login novamente."));
    }

    if (quizDetailMatch) {
      return toResponse(handleQuizDetail(quizDetailMatch[1]));
    }
    return toResponse(handleQuizAttemptSubmit(quizAttemptMatch![1], body, account.user.id));
  }

  const route = routes[`${method} ${url.pathname}`];

  if (!route) {
    return toResponse(errorResult(404, "NOT_FOUND", "Recurso não encontrado."));
  }

  if (!route.authenticated) {
    return toResponse(route.handle(body));
  }

  const account = resolveAccount(new Headers(init.headers).get("Authorization"));
  if (!account) {
    return toResponse(errorResult(401, "UNAUTHORIZED", "Sessão expirada. Faça login novamente."));
  }

  return toResponse(route.handle(body, account));
}
