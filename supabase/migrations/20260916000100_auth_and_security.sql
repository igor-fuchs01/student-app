-- Student App — Supabase Auth and row level security.
--
-- Security model: the anon key ships inside the browser bundle, so anyone can
-- call the REST API directly, without the app. Nothing here trusts the frontend:
--   * every table has RLS enabled, and a table without a policy returns no rows;
--   * students read only their own rows, plus content that has no answer keys;
--   * clients get no INSERT/UPDATE/DELETE policy: writes go through functions
--     that validate them on the server;
--   * views run with their owner's rights and would bypass RLS, so clients
--     can't reach them; their data is exposed only through the functions in
--     20260916000200_api_read_functions.sql, which return only allowed fields;
--   * SECURITY DEFINER functions pin search_path to '' and qualify every name,
--     and no function builds SQL from strings, so arguments never become SQL.

-- =============================================================================
-- 1. Supabase Auth replaces the app's own passwords and tokens
-- =============================================================================

alter table public.students drop column password_hash;

-- Accounts are created by the institution in Supabase Auth, with public signups
-- disabled ([auth] enable_signup = false in supabase/config.toml).
alter table public.students
  add column auth_user_id uuid not null unique references auth.users (id) on delete cascade;

drop table public.auth_tokens;

-- Runs with the caller's rights, so RLS on students limits it to the caller's own row.
create function public.current_student_id()
returns integer
language sql
stable
set search_path = ''
as $$
  select s.id from public.students s where s.auth_user_id = (select auth.uid())
$$;

revoke execute on function public.current_student_id() from public, anon;
grant execute on function public.current_student_id() to authenticated;

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
  using (student_id = (select public.current_student_id()));

create policy "students read their own answers"
  on public.quiz_attempt_answers for select to authenticated
  using (
    exists (
      select 1
      from public.quiz_attempts a
      where a.id = attempt_id and a.student_id = (select public.current_student_id())
    )
  );

create policy "students read their own study days"
  on public.student_activity_days for select to authenticated
  using (student_id = (select public.current_student_id()));

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
-- 3. Nothing is public, and views stay internal
-- =============================================================================

revoke all on all tables in schema public from anon;

revoke all on
  public.v_subject_summary,
  public.v_student_subject_performance,
  public.v_student_topic_performance,
  public.v_quiz_summary,
  public.v_student_quiz_attempts,
  public.v_quiz_attempt_result,
  public.v_quiz_attempt_subject_performance,
  public.v_quiz_review_items,
  public.v_student_streak,
  public.v_student_ranking,
  public.v_student_ranking_profile
from authenticated;

