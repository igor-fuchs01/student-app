import { dashboardDataSchema, type DashboardData } from "@models/dashboard";
import { USE_MOCKS } from "./config";
import { API_ENDPOINTS } from "./endpoints";
import { httpClient } from "./httpClient";
import { supabaseDashboardApi } from "./supabase/dashboardApi";

const mockDashboardApi = {
  getDashboard(signal?: AbortSignal): Promise<DashboardData> {
    return httpClient.get(API_ENDPOINTS.dashboard, dashboardDataSchema, { signal });
  },
};

export const dashboardApi = USE_MOCKS ? mockDashboardApi : supabaseDashboardApi;
