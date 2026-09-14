import { rankingDataSchema, type RankingData } from "@models/ranking";
import { API_ENDPOINTS } from "./endpoints";
import { httpClient } from "./httpClient";

export const rankingApi = {
  getRanking(signal?: AbortSignal): Promise<RankingData> {
    return httpClient.get(API_ENDPOINTS.ranking, rankingDataSchema, { signal });
  },
};
