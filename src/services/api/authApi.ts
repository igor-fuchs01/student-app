import { z } from "zod";
import {
  authSessionSchema,
  registerResultSchema,
  type AuthSession,
  type LoginCredentials,
  type RegisterCredentials,
  type RegisterResult,
} from "@models/auth";
import { USE_MOCKS } from "./config";
import { API_ENDPOINTS } from "./endpoints";
import { httpClient } from "./httpClient";
import { supabaseAuthApi } from "./supabase/authApi";

// The mock server checks no captcha, so it takes no captcha token.
const mockAuthApi = {
  login(credentials: LoginCredentials): Promise<AuthSession> {
    return httpClient.post(API_ENDPOINTS.auth.login, authSessionSchema, credentials, {
      authenticated: false,
    });
  },

  logout(): Promise<void> {
    return httpClient.post(API_ENDPOINTS.auth.logout, z.void());
  },

  register(credentials: RegisterCredentials): Promise<RegisterResult> {
    return httpClient.post(API_ENDPOINTS.auth.register, registerResultSchema, credentials, {
      authenticated: false,
    });
  },
};

export const authApi = USE_MOCKS ? mockAuthApi : supabaseAuthApi;
