import { subjectsResponseSchema, type Subject } from "@models/subjects";
import { API_ENDPOINTS } from "./endpoints";
import { httpClient } from "./httpClient";

export const subjectsApi = {
  getSubjects(signal?: AbortSignal): Promise<Subject[]> {
    return httpClient.get(API_ENDPOINTS.subjects, subjectsResponseSchema, { signal });
  },
};
