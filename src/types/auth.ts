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

// First access with an access code from the operator's list: the student chooses the password.
// 72 is the most bcrypt reads, so a longer password would be silently cut.
export const registerCredentialsSchema = loginCredentialsSchema.extend({
  password: z
    .string()
    .min(6, "Use pelo menos 6 caracteres.")
    .max(72, "Use no máximo 72 caracteres."),
});

export type RegisterCredentials = z.infer<typeof registerCredentialsSchema>;

export const registerFormSchema = registerCredentialsSchema
  .extend({
    displayName: displayNameSchema,
    passwordConfirmation: z.string(),
  })
  .refine((form) => form.password === form.passwordConfirmation, {
    path: ["passwordConfirmation"],
    message: "As senhas não conferem.",
  });

export const registerResultSchema = z.object({
  accessCode: z.string().min(1),
});

export type RegisterResult = z.infer<typeof registerResultSchema>;

export const authSessionSchema = z.object({
  token: z.string().min(1),
  user: studentUserSchema,
});

export type AuthSession = z.infer<typeof authSessionSchema>;
