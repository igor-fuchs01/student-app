import {
  subjectDetailSchema,
  subjectsResponseSchema,
  type Subject,
  type SubjectDetail,
} from "@models/subjects";
import { callFunction } from "./callFunction";

export const supabaseSubjectsApi = {
  getSubjects(signal?: AbortSignal): Promise<Subject[]> {
    return callFunction("list-subjects", subjectsResponseSchema, { signal });
  },

  getSubject(id: string, signal?: AbortSignal): Promise<SubjectDetail> {
    return callFunction("get-subject", subjectDetailSchema, { query: { id }, signal });
  },
};
