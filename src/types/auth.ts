import { z } from "zod";

// No personal data: the name the student types stays in the browser (see displayNameStorage).
export const studentUserSchema = z.object({
  id: z.string().min(1),
  course: z.string(),
});

export type StudentUser = z.infer<typeof studentUserSchema>;

export const loginCredentialsSchema = z.object({
  accessCode: z
    .string()
    .trim()
    .toLowerCase()
    .min(1, "Informe seu código de acesso.")
    .regex(/^[a-z0-9]{6,32}$/, "Código de acesso inválido."),
  password: z.string().min(1, "Informe sua senha."),
});

export type LoginCredentials = z.infer<typeof loginCredentialsSchema>;

export const displayNameSchema = z
  .string()
  .trim()
  .min(1, "Informe como quer ser chamado.")
  .max(60, "Use no máximo 60 caracteres.");

export const loginFormSchema = loginCredentialsSchema.extend({
  displayName: displayNameSchema,
});

export const authSessionSchema = z.object({
  token: z.string().min(1),
  user: studentUserSchema,
});

export type AuthSession = z.infer<typeof authSessionSchema>;
