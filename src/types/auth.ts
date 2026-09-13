import { z } from "zod";

export const studentUserSchema = z.object({
  id: z.string().min(1),
  name: z.string().min(1),
  email: z.string().min(1),
  registrationId: z.string().min(1),
  course: z.string(),
});

export type StudentUser = z.infer<typeof studentUserSchema>;

export const loginCredentialsSchema = z.object({
  identifier: z.string().trim().min(1, "Informe sua matrícula ou e-mail institucional."),
  password: z.string().min(1, "Informe sua senha."),
});

export type LoginCredentials = z.infer<typeof loginCredentialsSchema>;

export const authSessionSchema = z.object({
  token: z.string().min(1),
  user: studentUserSchema,
});

export type AuthSession = z.infer<typeof authSessionSchema>;
