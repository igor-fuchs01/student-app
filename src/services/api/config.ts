import { z } from "zod";

const envSchema = z
  .object({
    VITE_USE_MOCKS: z.enum(["true", "false"]).default("false"),
    VITE_MOCK_DELAY_MS: z.coerce.number().int().nonnegative().default(500),
    VITE_API_BASE_URL: z.url({ protocol: /^https?$/ }).optional(),
  })
  .refine((env) => env.VITE_USE_MOCKS === "true" || Boolean(env.VITE_API_BASE_URL), {
    path: ["VITE_API_BASE_URL"],
    message: 'Required when VITE_USE_MOCKS is not "true". Set it in the .env file for this mode.',
  });

const env = envSchema.safeParse(import.meta.env);

if (!env.success) {
  throw new Error(
    `Invalid environment configuration (mode "${import.meta.env.MODE}"):\n${z.prettifyError(env.error)}`,
  );
}

export const USE_MOCKS = env.data.VITE_USE_MOCKS === "true";

export const MOCK_DELAY_MS = env.data.VITE_MOCK_DELAY_MS;

// Same-origin prefix intercepted by MSW; keeps mocked API calls apart from page routes like /ranking.
export const MOCK_API_BASE_URL = "/api";

export const API_BASE_URL = (env.data.VITE_API_BASE_URL ?? "").replace(/\/+$/, "");
