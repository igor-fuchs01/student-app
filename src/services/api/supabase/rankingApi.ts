import { rankingDataSchema, type RankingData } from "@models/ranking";
import { callFunction } from "./callFunction";

export const supabaseRankingApi = {
  getRanking(signal?: AbortSignal): Promise<RankingData> {
    return callFunction("get-ranking", rankingDataSchema, { signal });
  },
};
