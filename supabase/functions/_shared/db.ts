import postgres from "npm:postgres@3";

// Direct connection to the database as the postgres role, instead of the Data API: the queries
// reach the views in the private schema and can run in a transaction. The role bypasses row level
// security, so every query filters by the student that http.ts resolved from the JWT.
//
// The SQL only returns rows; the JSON of each contract DTO is built in TypeScript. Counts and
// percentages are cast to int and float8, which the driver returns as numbers (bigint and numeric
// would come back as strings). prepare is off because the hosted pooler runs in transaction mode.
//
// The hosted database accepts few connections, and every instance of every function holds its own
// client: DB_POOLER_URL (the transaction pooler, a secret set only in the hosted project) caps the
// real connections, one connection per instance is enough because the driver pipelines concurrent
// queries, and an idle connection is closed instead of being held until the instance shuts down.
export const sql = postgres(Deno.env.get("DB_POOLER_URL") ?? Deno.env.get("SUPABASE_DB_URL")!, {
  prepare: false,
  max: 1,
  idle_timeout: 10,
});
