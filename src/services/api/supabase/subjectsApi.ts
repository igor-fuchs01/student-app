import {
  subjectDetailSchema,
  subjectsResponseSchema,
  type Subject,
  type SubjectDetail,
} from "@models/subjects";
import { callRpc } from "./callRpc";

// get_subject is still missing from supabase/migrations (docs/05-melhorias-futuras.md, item 7):
// until the migration lands, the subject detail screen only works with VITE_USE_MOCKS=true.
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
