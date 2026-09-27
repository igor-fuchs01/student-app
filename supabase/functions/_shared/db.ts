import postgres from "npm:postgres@3";

// Direct connection to the database as the postgres role, instead of the Data API: the queries
// reach the views in the private schema and can run in a transaction. The role bypasses row level
// security, so every query filters by the student that http.ts resolved from the JWT.
//
// The SQL only returns rows; the JSON of each contract DTO is built in TypeScript. Counts and
// percentages are cast to int and float8, which the driver returns as numbers (bigint and numeric
// would come back as strings). prepare is off because the hosted pooler runs in transaction mode.
export const sql = postgres(Deno.env.get("SUPABASE_DB_URL")!, { prepare: false });
