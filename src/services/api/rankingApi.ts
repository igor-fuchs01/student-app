import {
  activityCalendarSchema,
  rankingDataSchema,
  type ActivityCalendar,
  type RankingData,
} from "@models/ranking";
import { USE_MOCKS } from "./config";
import { API_ENDPOINTS } from "./endpoints";
import { httpClient } from "./httpClient";
import { supabaseRankingApi } from "./supabase/rankingApi";

const mockRankingApi = {
  getRanking(signal?: AbortSignal): Promise<RankingData> {
    return httpClient.get(API_ENDPOINTS.ranking, rankingDataSchema, { signal });
  },

  getActivityCalendar(month: string, signal?: AbortSignal): Promise<ActivityCalendar> {
    const query = new URLSearchParams({ month });
    return httpClient.get(`${API_ENDPOINTS.activityCalendar}?${query}`, activityCalendarSchema, {
      signal,
    });
  },
};

export const rankingApi = USE_MOCKS ? mockRankingApi : supabaseRankingApi;
