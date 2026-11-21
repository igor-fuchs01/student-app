import { companiesResponseSchema, type Company } from "@models/companies";
import { USE_MOCKS } from "./config";
import { API_ENDPOINTS } from "./endpoints";
import { httpClient } from "./httpClient";
import { supabaseCompaniesApi } from "./supabase/companiesApi";

const mockCompaniesApi = {
  getCompanies(signal?: AbortSignal): Promise<Company[]> {
    return httpClient.get(API_ENDPOINTS.companies, companiesResponseSchema, { signal });
  },
};

export const companiesApi = USE_MOCKS ? mockCompaniesApi : supabaseCompaniesApi;
