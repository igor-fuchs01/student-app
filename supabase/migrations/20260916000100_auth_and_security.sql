-- Student App — Supabase Auth and row level security.
--
-- Security model: the anon key ships inside the browser bundle, so anyone can
-- call the REST API directly, without the app. Nothing here trusts the frontend:
--   * the endpoint functions are the whole API. No client role reaches a table,
--     a view or a helper through the Data API, so an endpoint is the only way in;
--   * RLS stays enabled on every table as the second layer: a table without a
--     policy returns no rows and a student reads only their own, so a privilege
--     granted by mistake still leaks nothing;
--   * clients get no INSERT/UPDATE/DELETE policy: writes go through functions
--     that validate them on the server;
--   * views run with their owner's rights and would bypass RLS, so they live in
--     the private schema, which the Data API does not serve; their data is exposed
--     only through the functions in 20260916000200_api_read_functions.sql, which
--     return only allowed fields;
--   * SECURITY DEFINER functions pin search_path to '' and qualify every name,
--     and no function builds SQL from strings, so arguments never become SQL.

-- =============================================================================
-- 1. The signed-in student
-- =============================================================================

-- Lets the policies below reach private.current_student_id(). It exposes nothing:
-- PostgREST only serves the schemas in [api] schemas of config.toml.
grant usage on schema private to authenticated;

-- Translates the Auth user of the current request into a students.id. SECURITY
-- DEFINER so a policy on students does not have to evaluate its own RLS again;
-- safe because it takes no argument and reads nothing but auth.uid().
create function private.current_student_id()
returns integer
language sql
stable
security definer
set search_path = ''
as $$
  select s.id from public.students s where s.auth_user_id = (select auth.uid())
$$;

grant execute on function private.current_student_id() to authenticated;

-- =============================================================================
-- 2. Row level security
-- =============================================================================

alter table public.students enable row level security;
alter table public.subjects enable row level security;
alter table public.topics enable row level security;
alter table public.materials enable row level security;
alter table public.questions enable row level security;
alter table public.question_options enable row level security;
alter table public.question_blanks enable row level security;
alter table public.question_blank_options enable row level security;
alter table public.question_terms enable row level security;
alter table public.question_slots enable row level security;
alter table public.quizzes enable row level security;
alter table public.quiz_questions enable row level security;
alter table public.scheduled_exams enable row level security;
alter table public.quiz_attempts enable row level security;
alter table public.quiz_attempt_answers enable row level security;
alter table public.student_activity_days enable row level security;

-- Own data only (docs/99-criterios-de-aceite-mvp.md: "acesso somente às próprias informações").
create policy "students read their own profile"
  on public.students for select to authenticated
  using (auth_user_id = (select auth.uid()));

create policy "students read their own attempts"
  on public.quiz_attempts for select to authenticated
  using (student_id = (select private.current_student_id()));

create policy "students read their own answers"
  on public.quiz_attempt_answers for select to authenticated
  using (
    exists (
      select 1
      from public.quiz_attempts a
      where a.id = attempt_id and a.student_id = (select private.current_student_id())
    )
  );

create policy "students read their own study days"
  on public.student_activity_days for select to authenticated
  using (student_id = (select private.current_student_id()));

-- Content without answer keys: readable by any signed-in student.
create policy "signed-in students read subjects"
  on public.subjects for select to authenticated using (true);

create policy "signed-in students read topics"
  on public.topics for select to authenticated using (true);

create policy "signed-in students read materials"
  on public.materials for select to authenticated using (true);

create policy "signed-in students read quizzes"
  on public.quizzes for select to authenticated using (true);

create policy "signed-in students read quiz questions order"
  on public.quiz_questions for select to authenticated using (true);

create policy "signed-in students read scheduled exams"
  on public.scheduled_exams for select to authenticated using (true);

-- questions, question_options, question_blanks, question_blank_options,
-- question_terms and question_slots have no policy on purpose: together they
-- hold the answer keys, so they can't be listed in bulk. A quiz is read one at
-- a time through get_quiz, which still includes its answer keys because the
-- current QuizDetail contract does (docs/05-melhorias-futuras.md, item 2).

-- =============================================================================
-- 3. The Data API reaches nothing but the endpoint functions
-- =============================================================================

-- The app never selects from a table: every endpoint of the contract is a
-- function, so no client role needs table access at all. That is what makes the
-- policies above a second layer instead of the only barrier. The views used to
-- need one revoke each; they are in a schema the Data API does not serve now.
revoke all on all tables in schema public from anon, authenticated;
revoke all on all sequences in schema public from anon, authenticated;

-- Supabase hands the Data API roles everything postgres creates in public, so
-- without this a table or function added later would become an endpoint by
-- accident. From here on each endpoint grants its own EXECUTE.
alter default privileges for role postgres in schema public revoke all on tables from anon, authenticated;
alter default privileges for role postgres in schema public revoke all on sequences from anon, authenticated;
alter default privileges for role postgres in schema public revoke execute on routines from public, anon, authenticated;

