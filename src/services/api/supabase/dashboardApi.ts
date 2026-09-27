import { dashboardDataSchema, type DashboardData } from "@models/dashboard";
import { callFunction } from "./callFunction";

export const supabaseDashboardApi = {
  getDashboard(signal?: AbortSignal): Promise<DashboardData> {
    return callFunction("get-dashboard", dashboardDataSchema, { signal });
  },
};
