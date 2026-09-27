-- Student App — grants.

-- The app never reaches the database through the Data API: every endpoint of the
-- contract is an edge function that connects directly, so no client role needs
-- access to any table, sequence or function. That is what makes the row level
-- security policies a second layer instead of the only barrier. The default
-- privileges revoked in the schemas migration already keep anon and
-- authenticated off everything created since; these revokes also cover whatever
-- Supabase granted to those roles before the migrations ran.
revoke all on all tables in schema public from anon, authenticated;
revoke all on all sequences in schema public from anon, authenticated;
revoke execute on all routines in schema public from public, anon, authenticated;

-- Lets the row level security policies reach private.current_student_id().
-- Granting usage on private exposes nothing on its own: PostgREST serves only
-- the schemas in [api] schemas of supabase/config.toml, and every other routine
-- in private stays unexecutable by this role.
grant usage on schema private to authenticated;
grant execute on function private.current_student_id() to authenticated;
