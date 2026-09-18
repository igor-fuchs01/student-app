import { rankingDataSchema, type RankingData } from "@models/ranking";
import { USE_MOCKS } from "./config";
import { API_ENDPOINTS } from "./endpoints";
import { httpClient } from "./httpClient";
import { supabaseRankingApi } from "./supabase/rankingApi";

const mockRankingApi = {
  getRanking(signal?: AbortSignal): Promise<RankingData> {
    return httpClient.get(API_ENDPOINTS.ranking, rankingDataSchema, { signal });
  },
};

export const rankingApi = USE_MOCKS ? mockRankingApi : supabaseRankingApi;
