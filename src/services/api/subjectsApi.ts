import {
  subjectDetailSchema,
  subjectsResponseSchema,
  type Subject,
  type SubjectDetail,
} from "@models/subjects";
import { USE_MOCKS } from "./config";
import { API_ENDPOINTS } from "./endpoints";
import { httpClient } from "./httpClient";
import { supabaseSubjectsApi } from "./supabase/subjectsApi";

const mockSubjectsApi = {
  getSubjects(signal?: AbortSignal): Promise<Subject[]> {
    return httpClient.get(API_ENDPOINTS.subjects.list, subjectsResponseSchema, { signal });
  },

  getSubject(id: string, signal?: AbortSignal): Promise<SubjectDetail> {
    return httpClient.get(API_ENDPOINTS.subjects.detail(id), subjectDetailSchema, { signal });
  },
};

export const subjectsApi = USE_MOCKS ? mockSubjectsApi : supabaseSubjectsApi;
