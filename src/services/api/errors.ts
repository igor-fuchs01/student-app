import { z } from "zod";

const API_ERROR_CODES = [
  "VALIDATION_ERROR",
  "INVALID_CREDENTIALS",
  "UNAUTHORIZED",
  "NOT_FOUND",
  "NETWORK_ERROR",
  "INVALID_RESPONSE",
  "UNKNOWN_ERROR",
] as const;

export type ApiErrorCode = (typeof API_ERROR_CODES)[number];

export const NETWORK_ERROR_MESSAGE =
  "Não foi possível conectar ao servidor. Verifique sua conexão.";

export const INVALID_RESPONSE_MESSAGE =
  "Recebemos uma resposta inválida do servidor. Tente novamente.";

export const INVALID_CREDENTIALS_MESSAGE = "E-mail ou senha inválidos.";

export const UNKNOWN_ERROR_MESSAGE = "Ocorreu um erro inesperado. Tente novamente.";

export const SESSION_EXPIRED_MESSAGE = "Sessão expirada. Faça login novamente.";

export const apiErrorBodySchema = z.object({
  code: z.enum(API_ERROR_CODES).catch("UNKNOWN_ERROR"),
  message: z.string().min(1),
});

export type ApiErrorBody = z.infer<typeof apiErrorBodySchema>;

export class ApiError extends Error {
  readonly status: number;
  readonly code: ApiErrorCode;

  constructor(status: number, code: ApiErrorCode, message: string) {
    super(message);
    this.name = "ApiError";
    this.status = status;
    this.code = code;
  }
}
