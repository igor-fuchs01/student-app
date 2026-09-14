import { create } from "zustand";
import type { LoginCredentials, StudentUser } from "@models/auth";
import { authApi } from "@services/api/authApi";
import { onUnauthorized } from "@services/api/httpClient";
import { tokenStorage } from "@services/storage/tokenStorage";

type AuthStatus = "idle" | "authenticating" | "authenticated" | "error";

type AuthState = {
  status: AuthStatus;
  user: StudentUser | null;
  login: (credentials: LoginCredentials) => Promise<void>;
  logout: () => Promise<void>;
};

const signedOutState = {
  status: "idle",
  user: null,
} as const;

const existingSession = tokenStorage.getSession();

export const useAuthStore = create<AuthState>((set) => ({
  status: existingSession ? "authenticated" : "idle",
  user: existingSession?.user ?? null,

  async login(credentials) {
    set({ status: "authenticating" });
    try {
      const session = await authApi.login(credentials);
      tokenStorage.saveSession(session);
      set({ status: "authenticated", user: session.user });
    } catch (err) {
      set({ status: "error" });
      throw err;
    }
  },

  async logout() {
    await authApi.logout().catch(() => undefined);
    tokenStorage.clearSession();
    set(signedOutState);
  },
}));

onUnauthorized(() => useAuthStore.setState(signedOutState));
