import { z } from "zod";

const envSchema = z
  .object({
    VITE_USE_MOCKS: z.enum(["true", "false"]).default("false"),
    VITE_MOCK_DELAY_MS: z.coerce.number().int().nonnegative().default(500),
    VITE_SUPABASE_URL: z.url({ protocol: /^https?$/ }).optional(),
    VITE_SUPABASE_PUBLISHABLE_KEY: z.string().min(1).optional(),
  })
  .refine(
    (env) =>
      env.VITE_USE_MOCKS === "true" ||
      (Boolean(env.VITE_SUPABASE_URL) && Boolean(env.VITE_SUPABASE_PUBLISHABLE_KEY)),
    {
      path: ["VITE_SUPABASE_URL"],
      message:
        'VITE_SUPABASE_URL and VITE_SUPABASE_PUBLISHABLE_KEY are required when VITE_USE_MOCKS is not "true". Set them in the .env file for this mode.',
    },
  );

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

export const SUPABASE_URL = env.data.VITE_SUPABASE_URL ?? "";

export const SUPABASE_PUBLISHABLE_KEY = env.data.VITE_SUPABASE_PUBLISHABLE_KEY ?? "";
