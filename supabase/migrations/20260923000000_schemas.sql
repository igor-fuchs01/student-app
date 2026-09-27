-- Student App — schemas and default privileges.
--
-- The database is split into one migration per concern, applied in file order:
-- schemas, enums, tables (students, content, questions, quizzes, attempts),
-- views, row level security and grants. The API itself is not here: every
-- endpoint is an edge function in supabase/functions/, which reads these tables
-- and views and builds the JSON of the contract in TypeScript. Together they
-- are the physical model derived from the API contracts in
-- docs/04-contratos-de-api.md, the domain rules in
-- docs/02-regras-de-negocio.md and the MVP acceptance criteria in
-- docs/99-criterios-de-aceite-mvp.md. The conceptual and logical models are
-- explained in docs/06-modelagem-de-dados.md. From here on each change is a
-- new migration, never an edit to these files.
--
-- Conventions:
--   * table-level constraints are named, so errors and later migrations can
--     reference them; column-level ones keep the predictable Postgres name;
--   * every foreign key states its on delete action explicitly: cascade when
--     the child cannot exist without the parent, restrict when deleting the
--     parent would destroy history;
--   * comment on table documents each table inside the database itself;
--   * fields the API computes from other rows (counts, percentages, streak,
--     ranking position) are views, never stored columns; the result of an
--     attempt is computed by the submit-quiz-attempt edge function;
--   * public holds the tables and nothing else: every view and helper lives in
--     private, which the Data API never serves;
--   * no JSON is built or stored in SQL: answers with several values are rows
--     of their own, and the DTOs are assembled by the edge functions;
--   * every function pins search_path = '' and qualifies each name;
--   * no personal data is stored: a student is identified by the Auth account,
--     whose login is an access code, and the name stays in the browser.

-- Everything the app must not reach directly. It is left out of the Data API
-- schemas ([api] schemas in supabase/config.toml), so PostgREST never sees it.
create schema private;

comment on schema private is 'Internal views and helpers; not served by the Data API.';

-- Postgres makes every new function executable by public, and Supabase hands the
-- Data API roles everything postgres creates in public. Both defaults are
-- revoked here, before any function exists, so no routine ever exists with
-- execute granted to a client role.
alter default privileges for role postgres in schema private revoke execute on routines from public;
alter default privileges for role postgres in schema public revoke execute on routines from public, anon, authenticated;
alter default privileges for role postgres in schema public revoke all on tables from anon, authenticated;
alter default privileges for role postgres in schema public revoke all on sequences from anon, authenticated;
