-- Student App — grants.

-- The app never selects from a table: every endpoint of the contract is a
-- function, so no client role needs table access at all. That is what makes the
-- row level security policies a second layer instead of the only barrier. The
-- default privileges revoked in the schemas migration already keep anon and
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

-- The API surface, one function at a time: an explicit allowlist, so a helper
-- created in public by mistake is not reachable, and adding an endpoint means
-- adding its grant on purpose.
grant execute on function public.list_quizzes() to authenticated;
grant execute on function public.get_quiz(integer) to authenticated;

-- submit_quiz_attempt trusts its p_auth_user_id argument, so only the
-- submit-quiz-attempt edge function may call it: it runs as service_role after
-- verifying the student's JWT and validating the body with zod. A student
-- calling the RPC directly through the Data API is refused.
grant execute on function public.submit_quiz_attempt(uuid, integer, jsonb) to service_role;
