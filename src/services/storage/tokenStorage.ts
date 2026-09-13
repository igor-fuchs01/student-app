import { studentUserSchema, type AuthSession } from "@models/auth";

const TOKEN_KEY = "student-app:token";
const USER_KEY = "student-app:user";

export const tokenStorage = {
  getToken(): string | null {
    return localStorage.getItem(TOKEN_KEY);
  },

  getSession(): AuthSession | null {
    const token = localStorage.getItem(TOKEN_KEY);
    const rawUser = localStorage.getItem(USER_KEY);
    if (!token || !rawUser) return null;

    try {
      const user = studentUserSchema.safeParse(JSON.parse(rawUser));
      return user.success ? { token, user: user.data } : null;
    } catch {
      return null;
    }
  },

  saveSession(session: AuthSession): void {
    localStorage.setItem(TOKEN_KEY, session.token);
    localStorage.setItem(USER_KEY, JSON.stringify(session.user));
  },

  clearSession(): void {
    localStorage.removeItem(TOKEN_KEY);
    localStorage.removeItem(USER_KEY);
  },
};
