import { createClient, type SupabaseClient } from "@supabase/supabase-js";
import { SUPABASE_PUBLISHABLE_KEY, SUPABASE_URL } from "./config";

let client: SupabaseClient | undefined;

// Created on first use: in mock mode there is no Supabase URL, and createClient throws without one.
// The publishable key is public by design; RLS and function grants decide what it can reach.
export function getSupabase(): SupabaseClient {
  client ??= createClient(SUPABASE_URL, SUPABASE_PUBLISHABLE_KEY);
  return client;
}
