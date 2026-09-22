import {
  delay,
  http,
  HttpResponse,
  type DefaultBodyType,
  type HttpResponseResolver,
  type PathParams,
} from "msw";
import { loginCredentialsSchema, type AuthSession } from "@models/auth";
import { submitQuizAttemptSchema } from "@models/quizzes";
import { MOCK_API_BASE_URL, MOCK_DELAY_MS } from "../config";
import { API_ENDPOINTS } from "../endpoints";
import { INVALID_CREDENTIALS_MESSAGE, type ApiErrorBody, type ApiErrorCode } from "../errors";
import { buildMockDashboard } from "./dashboard";
import { createMockJwt, verifyMockJwt } from "./jwt";
import {
  buildMockQuizList,
  correctMockQuizAttempt,
  getMockQuizDetail,
  registerMockQuizAttempt,
} from "./quizzes";
import { buildMockRanking } from "./ranking";
import { buildMockSubjects, getMockSubjectDetail } from "./subjects";
import { findAccountByEmail, findAccountById, type MockAccount } from "./users";

type AuthenticatedInfo = {
  request: Request;
  params: PathParams;
  account: MockAccount;
};

function api(path: string): string {
  return `${MOCK_API_BASE_URL}${path}`;
}

function errorResponse(status: number, code: ApiErrorCode, message: string) {
  const body: ApiErrorBody = { code, message };
  return HttpResponse.json(body, { status });
}

async function readJson(request: Request): Promise<unknown> {
  try {
    return await request.json();
  } catch {
    return undefined;
  }
}

async function resolveAccount(request: Request): Promise<MockAccount | undefined> {
  const token = request.headers.get("Authorization")?.match(/^Bearer (.+)$/)?.[1];
  if (!token) return undefined;
  const accountId = await verifyMockJwt(token);
  return accountId ? findAccountById(accountId) : undefined;
}

function authenticated(
  resolve: (info: AuthenticatedInfo) => Response | Promise<Response>,
): HttpResponseResolver<PathParams, DefaultBodyType, undefined> {
  return async ({ request, params }) => {
    const account = await resolveAccount(request);
    if (!account) {
      return errorResponse(401, "UNAUTHORIZED", "Sessão expirada. Faça login novamente.");
    }
    return resolve({ request, params, account });
  };
}

export const handlers = [
  // Returns nothing, so every API request is delayed and then falls through to its handler.
  http.all(api("/*"), async () => {
    await delay(MOCK_DELAY_MS);
  }),

  http.post(api(API_ENDPOINTS.auth.login), async ({ request }) => {
    const credentials = loginCredentialsSchema.safeParse(await readJson(request));
    if (!credentials.success) {
      return errorResponse(400, "VALIDATION_ERROR", "Informe e-mail e senha.");
    }

    const { email, password } = credentials.data;
    const account = findAccountByEmail(email);
    if (!account || account.password !== password) {
      return errorResponse(401, "INVALID_CREDENTIALS", INVALID_CREDENTIALS_MESSAGE);
    }

    const session: AuthSession = {
      token: await createMockJwt(account.user.id),
      user: account.user,
    };
    return HttpResponse.json(session);
  }),

  http.post(
    api(API_ENDPOINTS.auth.logout),
    authenticated(() => new HttpResponse(null, { status: 204 })),
  ),

  http.get(
    api(API_ENDPOINTS.dashboard),
    authenticated(() => HttpResponse.json(buildMockDashboard())),
  ),

  http.get(
    api(API_ENDPOINTS.subjects.list),
    authenticated(() => HttpResponse.json(buildMockSubjects())),
  ),

  http.get(
    api(API_ENDPOINTS.subjects.detail(":subjectId")),
    authenticated(({ params }) => {
      const subject = getMockSubjectDetail(String(params.subjectId));
      if (!subject) return errorResponse(404, "NOT_FOUND", "Disciplina não encontrada.");
      return HttpResponse.json(subject);
    }),
  ),

  http.get(
    api(API_ENDPOINTS.quizzes.list),
    authenticated(({ account }) => HttpResponse.json(buildMockQuizList(account.user.id))),
  ),

  http.get(
    api(API_ENDPOINTS.quizzes.detail(":quizId")),
    authenticated(({ params }) => {
      const quiz = getMockQuizDetail(String(params.quizId));
      if (!quiz) return errorResponse(404, "NOT_FOUND", "Simulado não encontrado.");
      return HttpResponse.json(quiz);
    }),
  ),

  http.post(
    api(API_ENDPOINTS.quizzes.submitAttempt(":quizId")),
    authenticated(async ({ request, params, account }) => {
      const payload = submitQuizAttemptSchema.safeParse(await readJson(request));
      if (!payload.success) {
        return errorResponse(400, "VALIDATION_ERROR", "Respostas inválidas.");
      }

      const quizId = String(params.quizId);
      const result = correctMockQuizAttempt(quizId, payload.data.answers);
      if (!result) return errorResponse(404, "NOT_FOUND", "Simulado não encontrado.");

      registerMockQuizAttempt(account.user.id, quizId);
      return HttpResponse.json(result);
    }),
  ),

  http.get(
    api(API_ENDPOINTS.ranking),
    authenticated(({ account }) => HttpResponse.json(buildMockRanking(account.user))),
  ),

  http.all(api("/*"), () => errorResponse(404, "NOT_FOUND", "Recurso não encontrado.")),
];
