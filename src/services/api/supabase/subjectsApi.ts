import {
  subjectDetailSchema,
  subjectsResponseSchema,
  type Subject,
  type SubjectDetail,
} from "@models/subjects";
import { callRpc } from "./callRpc";

export const supabaseSubjectsApi = {
  getSubjects(signal?: AbortSignal): Promise<Subject[]> {
    return callRpc("list_subjects", subjectsResponseSchema, { signal });
  },

  getSubject(id: string, signal?: AbortSignal): Promise<SubjectDetail> {
    return callRpc("get_subject", subjectDetailSchema, {
      args: { p_subject_id: Number(id) },
      signal,
    });
  },
};
