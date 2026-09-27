import { create } from "zustand";
import type { LoginCredentials, StudentUser } from "@models/auth";
import { authApi } from "@services/api/authApi";
import { onUnauthorized } from "@services/api/httpClient";
import { displayNameStorage } from "@services/storage/displayNameStorage";
import { tokenStorage } from "@services/storage/tokenStorage";

type AuthStatus = "idle" | "authenticating" | "authenticated" | "error";

type AuthState = {
  status: AuthStatus;
  user: StudentUser | null;
  displayName: string | null;
  login: (credentials: LoginCredentials, displayName: string) => Promise<void>;
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
  displayName: displayNameStorage.get(),

  async login(credentials, displayName) {
    set({ status: "authenticating" });
    try {
      const session = await authApi.login(credentials);
      tokenStorage.saveSession(session);
      displayNameStorage.save(displayName);
      set({ status: "authenticated", user: session.user, displayName });
    } catch (err) {
      set({ status: "error" });
      throw err;
    }
  },

  async logout() {
    await authApi.logout().catch(() => undefined);
    tokenStorage.clearSession();
    displayNameStorage.clear();
    set({ ...signedOutState, displayName: null });
  },
}));

onUnauthorized(() => useAuthStore.setState(signedOutState));
