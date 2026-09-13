import { dashboardDataSchema, type DashboardData } from "@models/dashboard";
import { API_ENDPOINTS } from "./endpoints";
import { httpClient } from "./httpClient";

export const dashboardApi = {
  getDashboard(signal?: AbortSignal): Promise<DashboardData> {
    return httpClient.get(API_ENDPOINTS.dashboard, dashboardDataSchema, { signal });
  },
};
