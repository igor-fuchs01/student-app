import { subjectsResponseSchema, type Subject } from "@models/subjects";
import { callRpc } from "./callRpc";

export const supabaseSubjectsApi = {
  getSubjects(signal?: AbortSignal): Promise<Subject[]> {
    return callRpc("list_subjects", subjectsResponseSchema, { signal });
  },
};
