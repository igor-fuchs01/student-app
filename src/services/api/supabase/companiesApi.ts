import { companiesResponseSchema, type Company } from "@models/companies";
import { callFunction } from "./callFunction";

export const supabaseCompaniesApi = {
  getCompanies(signal?: AbortSignal): Promise<Company[]> {
    return callFunction("list-companies", companiesResponseSchema, { signal });
  },
};
