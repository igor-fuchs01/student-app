import { create } from "zustand";
import type { LoginCredentials, StudentUser } from "@models/auth";
import { authApi } from "@services/api/authApi";
import { onUnauthorized } from "@services/api/httpClient";
import { tokenStorage } from "@services/storage/tokenStorage";

type AuthStatus = "idle" | "authenticating" | "authenticated" | "error";

type AuthState = {
  status: AuthStatus;
  token: string | null;
  user: StudentUser | null;
  error: string | null;
  login: (credentials: LoginCredentials) => Promise<void>;
  logout: () => Promise<void>;
};

const signedOutState = {
  status: "idle",
  token: null,
  user: null,
  error: null,
} as const;

const existingSession = tokenStorage.getSession();

export const useAuthStore = create<AuthState>((set) => ({
  status: existingSession ? "authenticated" : "idle",
  token: existingSession?.token ?? null,
  user: existingSession?.user ?? null,
  error: null,

  async login(credentials) {
    set({ status: "authenticating", error: null });
    try {
      const session = await authApi.login(credentials);
      tokenStorage.saveSession(session);
      set({ status: "authenticated", token: session.token, user: session.user, error: null });
    } catch (err) {
      const message = err instanceof Error ? err.message : "Não foi possível entrar.";
      set({ status: "error", error: message });
      throw err;
    }
  },

  async logout() {
    try {
      await authApi.logout();
    } finally {
      tokenStorage.clearSession();
      set(signedOutState);
    }
  },
}));

onUnauthorized(() => useAuthStore.setState(signedOutState));
