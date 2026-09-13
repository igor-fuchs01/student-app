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
