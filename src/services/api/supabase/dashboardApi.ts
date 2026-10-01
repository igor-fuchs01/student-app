import { dashboardDataSchema, type DashboardData, type DashboardFilters } from "@models/dashboard";
import { callFunction } from "./callFunction";

export const supabaseDashboardApi = {
  getDashboard(
    { period, subjectId }: DashboardFilters,
    signal?: AbortSignal,
  ): Promise<DashboardData> {
    const query: Record<string, string> = { period: String(period) };
    if (subjectId) query.subjectId = subjectId;
    return callFunction("get-dashboard", dashboardDataSchema, { query, signal });
  },
};
