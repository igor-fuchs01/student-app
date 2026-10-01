import { dashboardDataSchema, type DashboardData, type DashboardFilters } from "@models/dashboard";
import { USE_MOCKS } from "./config";
import { API_ENDPOINTS } from "./endpoints";
import { httpClient } from "./httpClient";
import { supabaseDashboardApi } from "./supabase/dashboardApi";

const mockDashboardApi = {
  getDashboard(
    { period, subjectId }: DashboardFilters,
    signal?: AbortSignal,
  ): Promise<DashboardData> {
    const query = new URLSearchParams({ period: String(period) });
    if (subjectId) query.set("subjectId", subjectId);
    return httpClient.get(`${API_ENDPOINTS.dashboard}?${query}`, dashboardDataSchema, { signal });
  },
};

export const dashboardApi = USE_MOCKS ? mockDashboardApi : supabaseDashboardApi;
