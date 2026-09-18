import { subjectsResponseSchema, type Subject } from "@models/subjects";
import { USE_MOCKS } from "./config";
import { API_ENDPOINTS } from "./endpoints";
import { httpClient } from "./httpClient";
import { supabaseSubjectsApi } from "./supabase/subjectsApi";

const mockSubjectsApi = {
  getSubjects(signal?: AbortSignal): Promise<Subject[]> {
    return httpClient.get(API_ENDPOINTS.subjects, subjectsResponseSchema, { signal });
  },
};

export const subjectsApi = USE_MOCKS ? mockSubjectsApi : supabaseSubjectsApi;
