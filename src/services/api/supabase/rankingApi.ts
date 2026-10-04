import {
  activityCalendarSchema,
  rankingDataSchema,
  type ActivityCalendar,
  type RankingData,
} from "@models/ranking";
import { callFunction } from "./callFunction";

export const supabaseRankingApi = {
  getRanking(signal?: AbortSignal): Promise<RankingData> {
    return callFunction("get-ranking", rankingDataSchema, { signal });
  },

  getActivityCalendar(month: string, signal?: AbortSignal): Promise<ActivityCalendar> {
    return callFunction("get-activity-calendar", activityCalendarSchema, {
      query: { month },
      signal,
    });
  },
};
