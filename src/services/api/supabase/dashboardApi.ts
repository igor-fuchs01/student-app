import { dashboardDataSchema, type DashboardData } from "@models/dashboard";
import { callRpc } from "./callRpc";

export const supabaseDashboardApi = {
  getDashboard(signal?: AbortSignal): Promise<DashboardData> {
    return callRpc("get_dashboard", dashboardDataSchema, { signal });
  },
};
