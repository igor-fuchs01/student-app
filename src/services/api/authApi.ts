import { z } from "zod";
import { authSessionSchema, type AuthSession, type LoginCredentials } from "@models/auth";
import { API_ENDPOINTS } from "./endpoints";
import { httpClient } from "./httpClient";

export const authApi = {
  login(credentials: LoginCredentials): Promise<AuthSession> {
    return httpClient.post(API_ENDPOINTS.auth.login, authSessionSchema, credentials, {
      authenticated: false,
    });
  },

  logout(): Promise<void> {
    return httpClient.post(API_ENDPOINTS.auth.logout, z.void());
  },
};
