import { rankingDataSchema, type RankingData } from "@models/ranking";
import { callRpc } from "./callRpc";

export const supabaseRankingApi = {
  getRanking(signal?: AbortSignal): Promise<RankingData> {
    return callRpc("get_ranking", rankingDataSchema, { signal });
  },
};
