-- Student App — database baseline.
--
-- Creates the whole database in one migration: the physical model derived from
-- the API contracts in docs/04-contratos-de-api.md, the domain rules in
-- docs/02-regras-de-negocio.md and the MVP acceptance criteria in
-- docs/99-criterios-de-aceite-mvp.md. The conceptual and logical models are
-- explained in docs/06-modelagem-de-dados.md.
--
-- It replaces the six migrations the project accreted before its first deploy
-- (initial schema, auth and security, read functions, submit_quiz_attempt,
-- subject detail content and get_subject), which had only ever been applied
-- locally. Squashing them dropped the alter table and backfill steps that
-- existed solely to carry a database that no longer exists from one shape to
-- the next: every column, constraint and view below is declared in its final
-- form. From here on the rule of docs/06-modelagem-de-dados.md holds again —
-- each change is a new migration, never an edit to this file.
--
-- Conventions:
--   * table-level constraints are named, so errors and later migrations can
--     reference them; column-level ones keep the predictable Postgres name;
--   * every foreign key states its on delete action explicitly: cascade when
--     the child cannot exist without the parent, restrict when deleting the
--     parent would destroy history;
--   * comment on table documents each table inside the database itself;
--   * fields the API computes from other rows (counts, percentages, streak,
--     ranking position, attempt result) are views, never stored columns;
--   * public holds the tables and the endpoint functions and nothing else:
--     every view and helper lives in private, which the Data API never serves;
--   * every function pins search_path = '' and qualifies each name, and none of
--     them builds SQL from strings, so an argument never becomes SQL.
--
-- Sections: 1 extensions and schemas, 2 enums, 3 tables, 4 indexes, 5 views,
-- 6 row level security, 7 API functions, 8 grants.


-- =============================================================================
-- 1. Extensions and schemas
-- =============================================================================

-- In extensions, not public: its functions would otherwise sit next to the
-- endpoints and be granted along with them.
create extension if not exists citext with schema extensions; -- case-insensitive email lookups/uniqueness

-- Everything the app must not reach directly. It is left out of the Data API
-- schemas ([api] schemas in supabase/config.toml), so PostgREST never sees it.
create schema private;

comment on schema private is 'Internal views and helpers; not served by the Data API.';

-- Postgres makes every new function executable by public, and Supabase hands the
-- Data API roles everything postgres creates in public. Both defaults are
-- revoked here, before section 7 creates a single function, so no routine ever
-- exists with execute granted to a client role: section 8 then hands out the
-- access the API needs, one grant at a time.
alter default privileges for role postgres in schema private revoke execute on routines from public;
alter default privileges for role postgres in schema public revoke execute on routines from public, anon, authenticated;
alter default privileges for role postgres in schema public revoke all on tables from anon, authenticated;
alter default privileges for role postgres in schema public revoke all on sequences from anon, authenticated;

-- =============================================================================
-- 2. Enums
-- =============================================================================

-- docs/04-contratos-de-api.md §3.12 Question.type
create type question_type as enum (
  'multiple_choice',
  'multiple_answer',
  'single_choice',
  'drag_and_drop',
  'essay',
  'essay_blanks'
);

-- docs/04-contratos-de-api.md §3.10 QuizSummary.difficulty
create type difficulty_level as enum ('easy', 'medium', 'hard');

-- docs/04-contratos-de-api.md §3.10 QuizSummary.subjectScope
create type quiz_subject_scope as enum ('single', 'all');

-- docs/02-regras-de-negocio.md §6. The API exposes pending_review as
-- 'self_review' (see submit_quiz_attempt).
create type review_status as enum ('correct', 'incorrect', 'pending_review');

-- =============================================================================
-- 3. Tables
-- =============================================================================

-- -----------------------------------------------------------------------------
-- 3.1 Students and auth (docs/04-contratos-de-api.md §3.1, §3.2, §1.3)
-- -----------------------------------------------------------------------------

create table students (
  id                 integer generated always as identity primary key,
  name               text not null check (btrim(name) <> ''),
  email              extensions.citext not null unique,
  course             text not null default '',
  weekly_goal_target integer not null default 50 check (weekly_goal_target > 0),
  -- Accounts are created by the institution in Supabase Auth, with public signups
  -- disabled ([auth] enable_signup = false in supabase/config.toml).
  auth_user_id       uuid not null unique references auth.users (id) on delete cascade
);

comment on table students is 'Pre-provisioned student accounts; there is no public signup.';
comment on column students.weekly_goal_target is 'Weekly goal in answered questions (RankingData.profile.weeklyGoalTarget).';

-- -----------------------------------------------------------------------------
-- 3.2 Content: subject -> topic -> subtopic -> material
--     (docs/02-regras-de-negocio.md §1, docs/04-contratos-de-api.md §3.16-§3.19)
-- -----------------------------------------------------------------------------

create table subjects (
  id          integer generated always as identity primary key,
  name        text not null check (btrim(name) <> ''),
  short_label text not null check (btrim(short_label) <> '')
);

comment on table subjects is 'Course subjects (disciplinas).';

create table topics (
  id          integer generated always as identity primary key,
  subject_id  integer not null references subjects (id) on delete cascade,
  number      integer not null,
  name        text not null check (btrim(name) <> ''),
  description text not null check (btrim(description) <> ''),
  constraint topics_number_check check (number >= 1),
  constraint topics_subject_id_name_key unique (subject_id, name),
  constraint topics_subject_id_number_key unique (subject_id, number)
);

comment on table topics is 'Topics (assuntos) of a subject, one per lesson of the ementa; the unit used to diagnose difficulties.';
comment on column topics.number is 'Lesson number in the ementa; the screen labels the assunto "Aula {number}", so reordering the list never renumbers it.';
comment on column topics.description is 'One sentence on what the assunto covers (SubjectTopic.description).';

create table subtopics (
  id          integer generated always as identity primary key,
  topic_id    integer not null references topics (id) on delete cascade,
  name        text not null check (btrim(name) <> ''),
  summary     text not null check (btrim(summary) <> ''),
  order_index integer not null,
  constraint subtopics_topic_id_name_key unique (topic_id, name),
  constraint subtopics_topic_id_order_index_key unique (topic_id, order_index)
);

comment on table subtopics is 'Subassuntos of an assunto; the unit the subject detail screen shows, with the short summary the student reviews before studying.';

create table subtopic_key_points (
  id          integer generated always as identity primary key,
  subtopic_id integer not null references subtopics (id) on delete cascade,
  text        text not null check (btrim(text) <> ''),
  order_index integer not null,
  constraint subtopic_key_points_subtopic_id_order_index_key unique (subtopic_id, order_index)
);

comment on table subtopic_key_points is 'Key points of a subassunto, in display order (Subtopic.keyPoints); plain text, like the summary.';

create table materials (
  id          integer generated always as identity primary key,
  subtopic_id integer not null references subtopics (id) on delete cascade,
  title       text not null check (btrim(title) <> ''),
  file_url    text not null check (btrim(file_url) <> '')
);

comment on table materials is 'Study materials (PDFs) of a subassunto.';

-- -----------------------------------------------------------------------------
-- 3.3 Questions (docs/04-contratos-de-api.md §3.12)
-- -----------------------------------------------------------------------------

-- The subject is reached through topic_id; storing it here too would be a
-- transitive dependency (docs/06-modelagem-de-dados.md, section 2.2).
create table questions (
  id               integer generated always as identity primary key,
  topic_id         integer not null references topics (id) on delete restrict,
  type             question_type not null,
  prompt           text, -- multiple_choice, multiple_answer, essay, essay_blanks
  template         text, -- single_choice, drag_and_drop, essay_blanks ("{{id}}" placeholders)
  explanation      text, -- multiple_choice, multiple_answer, single_choice, drag_and_drop
  max_length       integer, -- essay
  reference_answer text,    -- essay

  constraint questions_statement_per_type_check check (
    (type in ('multiple_choice', 'multiple_answer', 'essay') and prompt is not null)
    or (type in ('single_choice', 'drag_and_drop') and template is not null)
    or (type = 'essay_blanks' and prompt is not null and template is not null)
  ),
  constraint questions_explanation_per_type_check check (
    (type in ('multiple_choice', 'multiple_answer', 'single_choice', 'drag_and_drop'))
    = (explanation is not null)
  ),
  -- Written with is not null on both sides: a check that evaluates to null passes.
  constraint questions_essay_fields_check check (
    case
      when type = 'essay'
        then max_length is not null and max_length > 0 and reference_answer is not null
      else max_length is null and reference_answer is null
    end
  )
);

comment on table questions is 'Question bank; one row per question, with the columns required by its type.';

create table question_options (
  id          integer generated always as identity primary key,
  question_id integer not null references questions (id) on delete cascade,
  text        text not null check (btrim(text) <> ''),
  is_correct  boolean not null default false,
  order_index integer not null,
  constraint question_options_question_id_order_index_key unique (question_id, order_index)
);

comment on table question_options is 'Options of multiple_choice and multiple_answer questions.';

create table question_blanks (
  id               integer generated always as identity primary key,
  question_id      integer not null references questions (id) on delete cascade,
  blank_key        text not null check (btrim(blank_key) <> ''),
  reference_answer text, -- essay_blanks
  order_index      integer not null,
  constraint question_blanks_question_id_blank_key_key unique (question_id, blank_key)
);

comment on table question_blanks is 'Blanks of single_choice (dropdown) and essay_blanks (free text) questions; blank_key matches a {{id}} in questions.template.';

create table question_blank_options (
  id          integer generated always as identity primary key,
  blank_id    integer not null references question_blanks (id) on delete cascade,
  text        text not null check (btrim(text) <> ''),
  is_correct  boolean not null default false,
  order_index integer not null,
  constraint question_blank_options_blank_id_order_index_key unique (blank_id, order_index)
);

comment on table question_blank_options is 'Dropdown options of a single_choice blank.';

create table question_terms (
  id          integer generated always as identity primary key,
  question_id integer not null references questions (id) on delete cascade,
  text        text not null check (btrim(text) <> ''),
  order_index integer not null,
  constraint question_terms_question_id_order_index_key unique (question_id, order_index)
);

comment on table question_terms is 'Draggable terms of a drag_and_drop question.';

create table question_slots (
  id              integer generated always as identity primary key,
  question_id     integer not null references questions (id) on delete cascade,
  slot_key        text not null check (btrim(slot_key) <> ''),
  correct_term_id integer not null references question_terms (id) on delete cascade,
  order_index     integer not null,
  constraint question_slots_question_id_slot_key_key unique (question_id, slot_key)
);

comment on table question_slots is 'Drop targets of a drag_and_drop question; slot_key matches a {{id}} in questions.template.';

-- -----------------------------------------------------------------------------
-- 3.4 Quizzes and exams (docs/04-contratos-de-api.md §3.5, §3.10, §3.11)
-- -----------------------------------------------------------------------------

-- There is no attempt limit: QuizSummary.attemptsCount reports how many
-- attempts the student has already submitted (counted by list_quizzes).
create table quizzes (
  id               integer generated always as identity primary key,
  title            text not null check (btrim(title) <> ''),
  subject_scope    quiz_subject_scope not null,
  subject_id       integer references subjects (id) on delete restrict,
  duration_minutes integer not null check (duration_minutes > 0),
  difficulty       difficulty_level not null,

  constraint quizzes_subject_scope_check check ((subject_scope = 'single') = (subject_id is not null))
);

comment on table quizzes is 'Quizzes (simulados); subject_id is set only when subject_scope is single.';

create table quiz_questions (
  quiz_id     integer not null references quizzes (id) on delete cascade,
  question_id integer not null references questions (id) on delete restrict,
  order_index integer not null,
  constraint quiz_questions_pkey primary key (quiz_id, question_id),
  constraint quiz_questions_quiz_id_order_index_key unique (quiz_id, order_index)
);

comment on table quiz_questions is 'Questions of a quiz, in display order.';

create table scheduled_exams (
  id         integer generated always as identity primary key,
  subject_id integer not null references subjects (id) on delete cascade,
  exam_date  date not null,
  note       text not null default ''
);

comment on table scheduled_exams is 'Upcoming exams; backs DashboardData.nextExam.';

-- -----------------------------------------------------------------------------
-- 3.5 Attempts (docs/04-contratos-de-api.md §3.13, §3.14)
-- -----------------------------------------------------------------------------

-- The current contract creates an attempt only when it is submitted, so every
-- row here is one submitted attempt.
create table quiz_attempts (
  id           integer generated always as identity primary key,
  quiz_id      integer not null references quizzes (id) on delete restrict,
  student_id   integer not null references students (id) on delete cascade,
  submitted_at timestamptz not null default now()
);

comment on table quiz_attempts is 'One row per submitted attempt; counted by QuizSummary.attemptsCount.';

-- Only answered questions are stored: the client does not send questions left
-- blank or partially filled, and they count as unanswered in the result.
create table quiz_attempt_answers (
  id                  integer generated always as identity primary key,
  attempt_id          integer not null references quiz_attempts (id) on delete cascade,
  question_id         integer not null references questions (id) on delete restrict,
  selected_option_id  integer references question_options (id) on delete restrict, -- multiple_choice
  selected_option_ids jsonb, -- multiple_answer: option ids
  essay_text          text,  -- essay
  blank_answers       jsonb, -- single_choice / essay_blanks: {blankKey: value}
  slot_answers        jsonb, -- drag_and_drop: {slotKey: termId}
  review_status       review_status not null,

  constraint quiz_attempt_answers_attempt_id_question_id_key unique (attempt_id, question_id)
);

comment on table quiz_attempt_answers is 'One row per answered question; only the column matching the question type is filled.';

-- -----------------------------------------------------------------------------
-- 3.6 Gamification (docs/02-regras-de-negocio.md §11 — never based on grades)
-- -----------------------------------------------------------------------------

create table student_activity_days (
  student_id    integer not null references students (id) on delete cascade,
  activity_date date not null,
  constraint student_activity_days_pkey primary key (student_id, activity_date)
);

comment on table student_activity_days is 'One row per day the student studied; source of the streak.';

-- =============================================================================
-- 4. Indexes
-- =============================================================================

-- Only a foreign key that no unique constraint already indexes by its first
-- column needs an index of its own: Postgres does not index the referencing
-- side, and on delete has to find the child rows. That is why subtopics,
-- subtopic_key_points, question_options, question_blanks, question_blank_options,
-- question_terms, question_slots and quiz_attempt_answers are absent below —
-- each already has a unique constraint starting with its foreign key.
create index idx_materials_subtopic_id on materials (subtopic_id);
create index idx_questions_topic_id on questions (topic_id);
create index idx_question_slots_correct_term_id on question_slots (correct_term_id);
create index idx_quiz_questions_question_id on quiz_questions (question_id);
create index idx_scheduled_exams_subject_id on scheduled_exams (subject_id);
create index idx_quiz_attempts_student_id on quiz_attempts (student_id);
create index idx_quiz_attempts_quiz_id on quiz_attempts (quiz_id);
create index idx_quiz_attempt_answers_question_id on quiz_attempt_answers (question_id);

-- =============================================================================
-- 5. Views — derived fields (private: reachable only through the functions)
-- =============================================================================

-- Every percentage below is graded hits over graded answers, rounded to two
-- decimals, and null when nothing was graded; each caller decides what an absent
-- score shows as. Which answers count as graded differs per view, so the filter
-- stays at the call site.
create function private.percent(p_part bigint, p_total bigint)
returns numeric
language sql
immutable
set search_path = ''
as $$
  select round(100.0 * p_part / nullif(p_total, 0), 2)
$$;

-- Subject.materialsCount / questionsCount (§3.9). A material hangs from a
-- subassunto, so the count reaches it through subtopics.
create view private.v_subject_summary as
select
  s.id as subject_id,
  (
    select count(*)
    from materials m
    join subtopics st on st.id = m.subtopic_id
    join topics t on t.id = st.topic_id
    where t.subject_id = s.id
  ) as materials_count,
  (select count(*) from questions q join topics t on t.id = q.topic_id where t.subject_id = s.id) as questions_count
from subjects s;

-- Subject.preparationPercent (§3.9) and NextExam.overallPreparation (§3.5).
create view private.v_student_subject_performance as
select
  qa.student_id,
  t.subject_id,
  private.percent(
    count(*) filter (where qaa.review_status = 'correct'),
    count(*) filter (where qaa.review_status <> 'pending_review')
  ) as preparation_percent
from quiz_attempt_answers qaa
join quiz_attempts qa on qa.id = qaa.attempt_id
join questions q on q.id = qaa.question_id
join topics t on t.id = q.topic_id
group by qa.student_id, t.subject_id;

-- Source for NextExam.priorities (§3.6); the high/medium/low level is a
-- threshold applied by the application.
create view private.v_student_topic_performance as
select
  qa.student_id,
  q.topic_id,
  count(*) filter (where qaa.review_status <> 'pending_review') as graded_count,
  private.percent(
    count(*) filter (where qaa.review_status = 'correct'),
    count(*) filter (where qaa.review_status <> 'pending_review')
  ) as percent
from quiz_attempt_answers qaa
join quiz_attempts qa on qa.id = qaa.attempt_id
join questions q on q.id = qaa.question_id
group by qa.student_id, q.topic_id;

-- QuizSummary.questionCount (§3.10).
create view private.v_quiz_summary as
select
  quiz.id as quiz_id,
  count(qq.question_id) as question_count
from quizzes quiz
left join quiz_questions qq on qq.quiz_id = quiz.id
group by quiz.id;

-- QuizResult counters and scorePercent (§3.14). pending_review answers are left
-- out of the score; unanswered questions count in the denominator, which is why
-- the filter here is is distinct from and not <>.
create view private.v_quiz_attempt_result as
select
  qa.id as attempt_id,
  qa.quiz_id,
  qa.submitted_at,
  count(*) filter (where qaa.review_status = 'correct') as correct_count,
  count(*) filter (where qaa.review_status = 'incorrect') as incorrect_count,
  count(*) filter (where qaa.id is null) as unanswered_count,
  count(*) filter (where qaa.review_status = 'pending_review') as self_review_count,
  private.percent(
    count(*) filter (where qaa.review_status = 'correct'),
    count(*) filter (where qaa.review_status is distinct from 'pending_review')
  ) as score_percent
from quiz_attempts qa
join quiz_questions qq on qq.quiz_id = qa.quiz_id
left join quiz_attempt_answers qaa on qaa.attempt_id = qa.id and qaa.question_id = qq.question_id
group by qa.id;

-- QuizResult.subjectPerformance (§3.14), same rules as score_percent.
create view private.v_quiz_attempt_subject_performance as
select
  qa.id as attempt_id,
  t.subject_id,
  private.percent(
    count(*) filter (where qaa.review_status = 'correct'),
    count(*) filter (where qaa.review_status is distinct from 'pending_review')
  ) as percent
from quiz_attempts qa
join quiz_questions qq on qq.quiz_id = qa.quiz_id
join questions q on q.id = qq.question_id
join topics t on t.id = q.topic_id
left join quiz_attempt_answers qaa on qaa.attempt_id = qa.id and qaa.question_id = qq.question_id
group by qa.id, t.subject_id;

-- streakDays: consecutive activity days ending today or yesterday.
create view private.v_student_streak as
with islands as (
  select
    student_id,
    activity_date,
    activity_date - (row_number() over (partition by student_id order by activity_date))::int as island
  from student_activity_days
),
runs as (
  select student_id, max(activity_date) as run_end, count(*) as run_length
  from islands
  group by student_id, island
)
select distinct on (student_id)
  student_id,
  run_length as streak_days
from runs
where run_end >= current_date - 1
order by student_id, run_end desc;

-- RankingData.entries (§3.15).
create view private.v_student_ranking as
select
  s.id as student_id,
  s.name as student_name,
  coalesce(st.streak_days, 0) as streak_days,
  rank() over (order by coalesce(st.streak_days, 0) desc, s.name asc) as position
from students s
left join private.v_student_streak st on st.student_id = s.id;

-- RankingData.profile (§3.15).
create view private.v_student_ranking_profile as
select
  s.id as student_id,
  coalesce(st.streak_days, 0) as streak_days,
  s.weekly_goal_target,
  (
    select count(*)
    from quiz_attempt_answers qaa
    join quiz_attempts qa on qa.id = qaa.attempt_id
    where qa.student_id = s.id and qa.submitted_at >= date_trunc('week', now())
  ) as weekly_goal_completed,
  (
    select count(*)
    from quiz_attempt_answers qaa
    join quiz_attempts qa on qa.id = qaa.attempt_id
    where qa.student_id = s.id
  ) as questions_answered,
  (select count(*) from quiz_attempts qa where qa.student_id = s.id) as quizzes_completed
from students s
left join private.v_student_streak st on st.student_id = s.id;

-- =============================================================================
-- 6. Row level security
-- =============================================================================

-- Security model: the anon key ships inside the browser bundle, so anyone can
-- call the REST API directly, without the app. Nothing here trusts the frontend:
--   * the endpoint functions are the whole API. No client role reaches a table,
--     a view or a helper through the Data API, so an endpoint is the only way in;
--   * RLS stays enabled on every table as the second layer: a table without a
--     policy returns no rows and a student reads only their own, so a privilege
--     granted by mistake still leaks nothing;
--   * clients get no insert/update/delete policy: writes go through functions
--     that validate them on the server;
--   * views run with their owner's rights and would bypass RLS, so they live in
--     the private schema, which the Data API does not serve; their data is
--     exposed only through the functions of section 7, which return only allowed
--     fields.

-- Translates the Auth user of the current request into a students.id. security
-- definer so a policy on students does not have to evaluate its own RLS again;
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

alter table public.students enable row level security;
alter table public.subjects enable row level security;
alter table public.topics enable row level security;
alter table public.subtopics enable row level security;
alter table public.subtopic_key_points enable row level security;
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

create policy "signed-in students read subtopics"
  on public.subtopics for select to authenticated using (true);

create policy "signed-in students read subtopic key points"
  on public.subtopic_key_points for select to authenticated using (true);

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
-- 7. API functions
-- =============================================================================
--
-- Each function returns exactly the JSON shape of its contract DTO, so the
-- frontend validates it with the same zod schemas used by the mock.
--
-- Every client-facing function is security definer with search_path = '' and
-- fully qualified names, identifies the student only through auth.uid() (never
-- through an argument), and is executable by the authenticated role only. The
-- helpers and views they build on live in the private schema, which the Data API
-- does not serve, so public holds nothing but the endpoints themselves.

-- -----------------------------------------------------------------------------
-- 7.1 Internal helpers (private schema)
-- -----------------------------------------------------------------------------

-- Raises an error that PostgREST turns into this HTTP status and a body in the
-- ApiErrorBody shape ({ code, message }), with a Portuguese message for the student.
create function private.raise_api_error(p_status integer, p_code text, p_message text)
returns void
language plpgsql
set search_path = ''
as $$
begin
  raise sqlstate 'PGRST' using
    message = json_build_object('code', p_code, 'message', p_message)::text,
    detail = json_build_object('status', p_status, 'headers', json_build_object())::text;
end;
$$;

-- private.current_student_id() plus the 401 the endpoints owe the client.
create function private.require_student_id()
returns integer
language plpgsql
stable
set search_path = ''
as $$
declare
  v_student_id integer := private.current_student_id();
begin
  if v_student_id is null then
    perform private.raise_api_error(401, 'UNAUTHORIZED', 'Sessão expirada. Faça login novamente.');
  end if;

  return v_student_id;
end;
$$;

-- Same rule as src/features/quizzes/normalizeAnswerText.ts.
create function private.normalize_answer_text(p_text text)
returns text
language sql
immutable
set search_path = ''
as $$
  select lower(regexp_replace(btrim(coalesce(p_text, '')), '\s+', ' ', 'g'))
$$;

-- Replaces each {{key}} of a template with its value; unknown keys become "___".
create function private.fill_template(p_template text, p_values jsonb)
returns text
language plpgsql
immutable
set search_path = ''
as $$
declare
  v_key text;
  v_value text;
  v_result text := p_template;
begin
  for v_key, v_value in select key, value from jsonb_each_text(coalesce(p_values, '{}'::jsonb)) loop
    v_result := replace(v_result, '{{' || v_key || '}}', v_value);
  end loop;
  return regexp_replace(v_result, '\{\{\w+\}\}', '___', 'g');
end;
$$;

-- QuizReviewItem.promptExcerpt, same rule as the mock server.
create function private.question_prompt_excerpt(
  p_type public.question_type,
  p_prompt text,
  p_template text
)
returns text
language sql
immutable
set search_path = ''
as $$
  select case
    when length(v.text) <= 90 then v.text
    else regexp_replace(left(v.text, 89), '\s+$', '') || '…'
  end
  from (
    select case
      when p_type in ('single_choice', 'drag_and_drop')
        then private.fill_template(p_template, null)
      when p_type = 'essay_blanks'
        then p_prompt || ' ' || private.fill_template(p_template, null)
      else p_prompt
    end as text
  ) v
$$;

-- Question (docs/04-contratos-de-api.md §3.12), in the shape of its type.
create function private.question_json(p_question_id integer)
returns jsonb
language sql
stable
set search_path = ''
as $$
  select
    jsonb_build_object('type', q.type, 'id', q.id::text, 'subjectName', s.name)
    || case q.type
      when 'multiple_choice' then jsonb_build_object(
        'prompt', q.prompt,
        'options', options.list,
        'correctOptionId', (
          select o.id::text
          from public.question_options o
          where o.question_id = q.id and o.is_correct
          order by o.order_index
          limit 1
        ),
        'explanation', q.explanation
      )
      when 'multiple_answer' then jsonb_build_object(
        'prompt', q.prompt,
        'options', options.list,
        'correctOptionIds', (
          select coalesce(jsonb_agg(o.id::text order by o.order_index), '[]'::jsonb)
          from public.question_options o
          where o.question_id = q.id and o.is_correct
        ),
        'explanation', q.explanation
      )
      when 'single_choice' then jsonb_build_object(
        'template', q.template,
        'blanks', (
          select jsonb_agg(
            jsonb_build_object(
              'id', b.blank_key,
              'options', (
                select jsonb_agg(jsonb_build_object('id', bo.id::text, 'text', bo.text) order by bo.order_index)
                from public.question_blank_options bo
                where bo.blank_id = b.id
              ),
              'correctOptionId', (
                select bo.id::text
                from public.question_blank_options bo
                where bo.blank_id = b.id and bo.is_correct
                order by bo.order_index
                limit 1
              )
            )
            order by b.order_index
          )
          from public.question_blanks b
          where b.question_id = q.id
        ),
        'explanation', q.explanation
      )
      when 'drag_and_drop' then jsonb_build_object(
        'template', q.template,
        'terms', (
          select jsonb_agg(jsonb_build_object('id', term.id::text, 'text', term.text) order by term.order_index)
          from public.question_terms term
          where term.question_id = q.id
        ),
        'slots', (
          select jsonb_agg(
            jsonb_build_object('id', slot.slot_key, 'correctTermId', slot.correct_term_id::text)
            order by slot.order_index
          )
          from public.question_slots slot
          where slot.question_id = q.id
        ),
        'explanation', q.explanation
      )
      when 'essay' then jsonb_build_object(
        'prompt', q.prompt,
        'maxLength', q.max_length,
        'referenceAnswer', q.reference_answer
      )
      when 'essay_blanks' then jsonb_build_object(
        'prompt', q.prompt,
        'template', q.template,
        'blanks', (
          select jsonb_agg(
            jsonb_build_object('id', b.blank_key, 'referenceAnswer', b.reference_answer)
            order by b.order_index
          )
          from public.question_blanks b
          where b.question_id = q.id
        )
      )
    end
  from public.questions q
  join public.topics topic on topic.id = q.topic_id
  join public.subjects s on s.id = topic.subject_id
  cross join lateral (
    select coalesce(
      jsonb_agg(jsonb_build_object('id', o.id::text, 'text', o.text) order by o.order_index),
      '[]'::jsonb
    ) as list
    from public.question_options o
    where o.question_id = q.id
  ) options
  where q.id = p_question_id
$$;

-- -----------------------------------------------------------------------------
-- 7.2 Read endpoints
-- -----------------------------------------------------------------------------

-- StudentUser (§3.1): the signed-in student, returned after login.
create function public.get_current_student()
returns jsonb
language plpgsql
stable
security definer
set search_path = ''
as $$
declare
  v_student_id integer := private.require_student_id();
begin
  return (
    select jsonb_build_object(
      'id', s.id::text,
      'name', s.name,
      'email', s.email,
      'course', s.course
    )
    from public.students s
    where s.id = v_student_id
  );
end;
$$;

-- Subject[] (§3.9, GET /subjects).
create function public.list_subjects()
returns jsonb
language plpgsql
stable
security definer
set search_path = ''
as $$
declare
  v_student_id integer := private.require_student_id();
begin
  return (
    select coalesce(
      jsonb_agg(
        jsonb_build_object(
          'id', s.id::text,
          'name', s.name,
          'shortLabel', s.short_label,
          'materialsCount', summary.materials_count,
          'questionsCount', summary.questions_count,
          'preparationPercent', coalesce(performance.preparation_percent, 0)
        )
        order by s.name
      ),
      '[]'::jsonb
    )
    from public.subjects s
    join private.v_subject_summary summary on summary.subject_id = s.id
    left join private.v_student_subject_performance performance
      on performance.subject_id = s.id and performance.student_id = v_student_id
  );
end;
$$;

-- SubjectDetail (§3.16, GET /subjects/:id). The counters and the preparation
-- come from the same views list_subjects reads, so the two endpoints can never
-- disagree about a subject.
create function public.get_subject(p_subject_id integer)
returns jsonb
language plpgsql
stable
security definer
set search_path = ''
as $$
declare
  v_student_id integer := private.require_student_id();
  v_subject jsonb;
begin
  select jsonb_build_object(
    'id', s.id::text,
    'name', s.name,
    'shortLabel', s.short_label,
    'materialsCount', summary.materials_count,
    'questionsCount', summary.questions_count,
    'preparationPercent', coalesce(performance.preparation_percent, 0),
    -- Assuntos by number, the label the student reads (§3.17); subassuntos, key
    -- points and materials by the study order the team defined, which for
    -- materials is the order they were inserted in.
    'topics', (
      select coalesce(
        jsonb_agg(
          jsonb_build_object(
            'id', t.id::text,
            'number', t.number,
            'name', t.name,
            'description', t.description,
            'subtopics', (
              select coalesce(
                jsonb_agg(
                  jsonb_build_object(
                    'id', st.id::text,
                    'name', st.name,
                    'summary', st.summary,
                    'keyPoints', (
                      select coalesce(jsonb_agg(kp.text order by kp.order_index), '[]'::jsonb)
                      from public.subtopic_key_points kp
                      where kp.subtopic_id = st.id
                    ),
                    'materials', (
                      select coalesce(
                        jsonb_agg(
                          jsonb_build_object(
                            'id', m.id::text,
                            'title', m.title,
                            'fileUrl', m.file_url
                          )
                          order by m.id
                        ),
                        '[]'::jsonb
                      )
                      from public.materials m
                      where m.subtopic_id = st.id
                    )
                  )
                  order by st.order_index
                ),
                '[]'::jsonb
              )
              from public.subtopics st
              where st.topic_id = t.id
            )
          )
          order by t.number
        ),
        '[]'::jsonb
      )
      from public.topics t
      where t.subject_id = s.id
    )
  )
  into v_subject
  from public.subjects s
  join private.v_subject_summary summary on summary.subject_id = s.id
  left join private.v_student_subject_performance performance
    on performance.subject_id = s.id and performance.student_id = v_student_id
  where s.id = p_subject_id;

  if v_subject is null then
    perform private.raise_api_error(404, 'NOT_FOUND', 'Disciplina não encontrada.');
  end if;

  return v_subject;
end;
$$;

-- DashboardData (§3.4, GET /dashboard). todayPlan is always empty: study plans
-- are not persisted yet (docs/05-melhorias-futuras.md, item 4).
create function public.get_dashboard()
returns jsonb
language plpgsql
stable
security definer
set search_path = ''
as $$
declare
  v_student_id integer := private.require_student_id();
  v_streak_days integer;
  v_exam_date date;
  v_exam_note text;
  v_exam_subject_id integer;
  v_exam_subject_name text;
  v_next_exam jsonb;
  v_subject_count integer;
  v_subject_names text;
  v_quiz_count integer;
begin
  select coalesce(
    (select st.streak_days from private.v_student_streak st where st.student_id = v_student_id),
    0
  ) into v_streak_days;

  select e.exam_date, e.note, s.id, s.name
  into v_exam_date, v_exam_note, v_exam_subject_id, v_exam_subject_name
  from public.scheduled_exams e
  join public.subjects s on s.id = e.subject_id
  where e.exam_date >= current_date
  order by e.exam_date, e.id
  limit 1;

  if v_exam_subject_id is null then
    v_next_exam := jsonb_build_object(
      'subjectName', 'Nenhuma prova agendada',
      'dateLabel', 'Sem data',
      'note', 'As prioridades aparecem quando houver uma prova',
      'overallPreparation', 0,
      'priorities', '[]'::jsonb
    );
  else
    v_next_exam := jsonb_build_object(
      'subjectName', v_exam_subject_name,
      'dateLabel',
        (array['Segunda-feira', 'Terça-feira', 'Quarta-feira', 'Quinta-feira', 'Sexta-feira', 'Sábado', 'Domingo'])[extract(isodow from v_exam_date)::integer]
        || ', ' || to_char(v_exam_date, 'DD/MM'),
      'note', v_exam_note,
      'overallPreparation', coalesce(
        (
          select performance.preparation_percent
          from private.v_student_subject_performance performance
          where performance.student_id = v_student_id and performance.subject_id = v_exam_subject_id
        ),
        0
      ),
      'priorities', coalesce(
        (
          select jsonb_agg(
            jsonb_build_object(
              'id', topic.id::text,
              'topicName', topic.name,
              'level', case
                when performance.percent < 50 then 'high'
                when performance.percent < 80 then 'medium'
                else 'low'
              end
            )
            order by performance.percent, topic.name
          )
          from private.v_student_topic_performance performance
          join public.topics topic on topic.id = performance.topic_id
          where performance.student_id = v_student_id
            and topic.subject_id = v_exam_subject_id
            and performance.percent is not null
        ),
        '[]'::jsonb
      )
    );
  end if;

  select count(*), string_agg(s.name, ', ' order by s.name)
  into v_subject_count, v_subject_names
  from public.subjects s;

  select count(*) into v_quiz_count
  from private.v_quiz_summary summary
  where summary.question_count > 0;

  return jsonb_build_object(
    'streakDays', v_streak_days,
    'nextExam', v_next_exam,
    'todayPlan', '[]'::jsonb,
    'summaryCards', jsonb_build_array(
      jsonb_build_object(
        'id', 'subjects',
        'title', 'Disciplinas',
        'value', v_subject_count || case when v_subject_count = 1 then ' matéria' else ' matérias' end,
        'description', coalesce(v_subject_names || '.', 'Nenhuma disciplina cadastrada.')
      ),
      jsonb_build_object(
        'id', 'quizzes',
        'title', 'Simulados',
        'value', v_quiz_count || case when v_quiz_count = 1 then ' disponível' else ' disponíveis' end,
        'description', 'Por disciplina ou integrados, quantas vezes você quiser.'
      ),
      jsonb_build_object(
        'id', 'ranking',
        'title', 'Ranking',
        'value', v_streak_days || case when v_streak_days = 1 then ' dia de sequência' else ' dias de sequência' end,
        'description', 'Baseado em consistência de estudo, não em nota.'
      )
    )
  );
end;
$$;

-- QuizSummary[] (§3.10, GET /quizzes). Quizzes without questions are left out.
create function public.list_quizzes()
returns jsonb
language plpgsql
stable
security definer
set search_path = ''
as $$
declare
  v_student_id integer := private.require_student_id();
begin
  return (
    select coalesce(jsonb_agg(quiz.item order by quiz.is_integrated desc, quiz.title), '[]'::jsonb)
    from (
      select
        z.subject_scope = 'all' as is_integrated,
        z.title,
        jsonb_strip_nulls(
          jsonb_build_object(
            'id', z.id::text,
            'title', z.title,
            'subjectScope', z.subject_scope,
            'subjectName', s.name,
            'questionCount', summary.question_count,
            'durationMinutes', z.duration_minutes,
            'attemptsCount', (
              select count(*)
              from public.quiz_attempts a
              where a.quiz_id = z.id and a.student_id = v_student_id
            ),
            'difficulty', z.difficulty
          )
        ) as item
      from public.quizzes z
      join private.v_quiz_summary summary on summary.quiz_id = z.id
      left join public.subjects s on s.id = z.subject_id
      where summary.question_count > 0
    ) quiz
  );
end;
$$;

-- QuizDetail (§3.11, GET /quizzes/:id).
create function public.get_quiz(p_quiz_id integer)
returns jsonb
language plpgsql
stable
security definer
set search_path = ''
as $$
declare
  v_quiz jsonb;
begin
  perform private.require_student_id();

  select jsonb_build_object(
    'id', z.id::text,
    'title', z.title,
    'durationMinutes', z.duration_minutes,
    'questions', (
      select jsonb_agg(private.question_json(qq.question_id) order by qq.order_index)
      from public.quiz_questions qq
      where qq.quiz_id = z.id
    )
  )
  into v_quiz
  from public.quizzes z
  where z.id = p_quiz_id
    and exists (select 1 from public.quiz_questions qq where qq.quiz_id = z.id);

  if v_quiz is null then
    perform private.raise_api_error(404, 'NOT_FOUND', 'Simulado não encontrado.');
  end if;

  return v_quiz;
end;
$$;

-- RankingData (§3.15, GET /ranking). Other students expose only name and streak,
-- never grades (docs/02-regras-de-negocio.md §11).
create function public.get_ranking()
returns jsonb
language plpgsql
stable
security definer
set search_path = ''
as $$
declare
  v_student_id integer := private.require_student_id();
begin
  return jsonb_build_object(
    'profile', (
      select jsonb_build_object(
        'streakDays', profile.streak_days,
        'weeklyGoalCompleted', profile.weekly_goal_completed,
        'weeklyGoalTarget', profile.weekly_goal_target,
        'questionsAnswered', profile.questions_answered,
        'quizzesCompleted', profile.quizzes_completed
      )
      from private.v_student_ranking_profile profile
      where profile.student_id = v_student_id
    ),
    'entries', coalesce(
      (
        select jsonb_agg(
          jsonb_build_object(
            'position', ranking.position,
            'studentId', ranking.student_id::text,
            'studentName', ranking.student_name,
            'streakDays', ranking.streak_days,
            'isCurrentUser', ranking.student_id = v_student_id
          )
          order by ranking.position, ranking.student_name
        )
        from private.v_student_ranking ranking
      ),
      '[]'::jsonb
    )
  );
end;
$$;

-- -----------------------------------------------------------------------------
-- 7.3 Write endpoint
-- -----------------------------------------------------------------------------

-- The only rejection the grading below ever gives back: a 400 that never says
-- which answer was refused, whatever the reason (a non-numeric id, an id from
-- another question or quiz, an essay past its limit, a repeated question).
create function private.reject_answers()
returns void
language plpgsql
set search_path = ''
as $$
begin
  perform private.raise_api_error(400, 'VALIDATION_ERROR', 'Respostas inválidas.');
end;
$$;

create function public.submit_quiz_attempt(p_quiz_id integer, p_answers jsonb)
returns jsonb
language plpgsql
volatile
security definer
set search_path = ''
as $$
declare
  v_student_id integer := private.require_student_id();
  v_attempt_id integer;
  v_answer jsonb;
  v_question public.questions%rowtype;
  v_question_id integer;
  v_option_id integer;
  v_selected integer[];
  v_expected integer[];
  v_values jsonb;
  v_status public.review_status;
begin
  if not exists (select 1 from public.quiz_questions qq where qq.quiz_id = p_quiz_id) then
    perform private.raise_api_error(404, 'NOT_FOUND', 'Simulado não encontrado.');
  end if;

  if p_answers is null or jsonb_typeof(p_answers) <> 'array' then
    perform private.reject_answers();
  end if;

  insert into public.quiz_attempts (quiz_id, student_id)
  values (p_quiz_id, v_student_id)
  returning id into v_attempt_id;

  for v_answer in select value from jsonb_array_elements(p_answers) loop
    if jsonb_typeof(v_answer) <> 'object' or coalesce(v_answer ->> 'questionId', '') !~ '^[0-9]{1,9}$' then
      perform private.reject_answers();
    end if;
    v_question_id := (v_answer ->> 'questionId')::integer;

    select q.* into v_question
    from public.questions q
    join public.quiz_questions qq on qq.question_id = q.id and qq.quiz_id = p_quiz_id
    where q.id = v_question_id;

    if not found or exists (
      select 1 from public.quiz_attempt_answers a
      where a.attempt_id = v_attempt_id and a.question_id = v_question_id
    ) then
      perform private.reject_answers();
    end if;

    -- Stays null when the question was left blank or partially filled: no row, counted as unanswered.
    v_status := null;

    case v_question.type
      when 'multiple_choice' then
        if coalesce(v_answer ->> 'optionId', '') <> '' then
          if (v_answer ->> 'optionId') !~ '^[0-9]{1,9}$' then
            perform private.reject_answers();
          end if;
          v_option_id := (v_answer ->> 'optionId')::integer;

          if not exists (
            select 1 from public.question_options o
            where o.id = v_option_id and o.question_id = v_question_id
          ) then
            perform private.reject_answers();
          end if;

          v_status := case
            when exists (select 1 from public.question_options o where o.id = v_option_id and o.is_correct)
              then 'correct'
            else 'incorrect'
          end;

          insert into public.quiz_attempt_answers (attempt_id, question_id, selected_option_id, review_status)
          values (v_attempt_id, v_question_id, v_option_id, v_status);
        end if;

      when 'multiple_answer' then
        if jsonb_typeof(v_answer -> 'optionIds') = 'array' and jsonb_array_length(v_answer -> 'optionIds') > 0 then
          if exists (
            select 1 from jsonb_array_elements(v_answer -> 'optionIds') e
            where jsonb_typeof(e) <> 'string' or (e #>> '{}') !~ '^[0-9]{1,9}$'
          ) then
            perform private.reject_answers();
          end if;

          select array_agg(distinct (e #>> '{}')::integer order by (e #>> '{}')::integer)
          into v_selected
          from jsonb_array_elements(v_answer -> 'optionIds') e;

          if exists (
            select 1 from unnest(v_selected) selected(id)
            where not exists (
              select 1 from public.question_options o
              where o.id = selected.id and o.question_id = v_question_id
            )
          ) then
            perform private.reject_answers();
          end if;

          select coalesce(array_agg(o.id order by o.id), '{}')
          into v_expected
          from public.question_options o
          where o.question_id = v_question_id and o.is_correct;

          v_status := case when v_selected = v_expected then 'correct' else 'incorrect' end;

          insert into public.quiz_attempt_answers (attempt_id, question_id, selected_option_ids, review_status)
          values (v_attempt_id, v_question_id, to_jsonb(v_selected), v_status);
        end if;

      when 'single_choice' then
        if jsonb_typeof(v_answer -> 'blankAnswers') = 'object' and not exists (
          select 1 from public.question_blanks b
          where b.question_id = v_question_id
            and coalesce(v_answer -> 'blankAnswers' ->> b.blank_key, '') = ''
        ) then
          if exists (
            select 1 from public.question_blanks b
            where b.question_id = v_question_id
              and (v_answer -> 'blankAnswers' ->> b.blank_key) !~ '^[0-9]{1,9}$'
          ) then
            perform private.reject_answers();
          end if;

          if exists (
            select 1 from public.question_blanks b
            where b.question_id = v_question_id
              and not exists (
                select 1 from public.question_blank_options bo
                where bo.blank_id = b.id
                  and bo.id = (v_answer -> 'blankAnswers' ->> b.blank_key)::integer
              )
          ) then
            perform private.reject_answers();
          end if;

          v_status := case
            when not exists (
              select 1 from public.question_blanks b
              where b.question_id = v_question_id
                and not exists (
                  select 1 from public.question_blank_options bo
                  where bo.blank_id = b.id
                    and bo.is_correct
                    and bo.id = (v_answer -> 'blankAnswers' ->> b.blank_key)::integer
                )
            ) then 'correct'
            else 'incorrect'
          end;

          -- Only the question's own blanks are stored, whatever else the client sent.
          select jsonb_object_agg(b.blank_key, v_answer -> 'blankAnswers' ->> b.blank_key)
          into v_values
          from public.question_blanks b
          where b.question_id = v_question_id;

          insert into public.quiz_attempt_answers (attempt_id, question_id, blank_answers, review_status)
          values (v_attempt_id, v_question_id, v_values, v_status);
        end if;

      when 'drag_and_drop' then
        if jsonb_typeof(v_answer -> 'slotAnswers') = 'object' and not exists (
          select 1 from public.question_slots slot
          where slot.question_id = v_question_id
            and coalesce(v_answer -> 'slotAnswers' ->> slot.slot_key, '') = ''
        ) then
          if exists (
            select 1 from public.question_slots slot
            where slot.question_id = v_question_id
              and (v_answer -> 'slotAnswers' ->> slot.slot_key) !~ '^[0-9]{1,9}$'
          ) then
            perform private.reject_answers();
          end if;

          if exists (
            select 1 from public.question_slots slot
            where slot.question_id = v_question_id
              and not exists (
                select 1 from public.question_terms term
                where term.question_id = v_question_id
                  and term.id = (v_answer -> 'slotAnswers' ->> slot.slot_key)::integer
              )
          ) then
            perform private.reject_answers();
          end if;

          v_status := case
            when not exists (
              select 1 from public.question_slots slot
              where slot.question_id = v_question_id
                and slot.correct_term_id <> (v_answer -> 'slotAnswers' ->> slot.slot_key)::integer
            ) then 'correct'
            else 'incorrect'
          end;

          select jsonb_object_agg(slot.slot_key, v_answer -> 'slotAnswers' ->> slot.slot_key)
          into v_values
          from public.question_slots slot
          where slot.question_id = v_question_id;

          insert into public.quiz_attempt_answers (attempt_id, question_id, slot_answers, review_status)
          values (v_attempt_id, v_question_id, v_values, v_status);
        end if;

      when 'essay' then
        if btrim(coalesce(v_answer ->> 'text', '')) <> '' then
          if length(v_answer ->> 'text') > v_question.max_length then
            perform private.reject_answers();
          end if;

          v_status := case
            when private.normalize_answer_text(v_answer ->> 'text')
              = private.normalize_answer_text(v_question.reference_answer)
              then 'correct'
            else 'pending_review'
          end;

          insert into public.quiz_attempt_answers (attempt_id, question_id, essay_text, review_status)
          values (v_attempt_id, v_question_id, v_answer ->> 'text', v_status);
        end if;

      when 'essay_blanks' then
        if jsonb_typeof(v_answer -> 'blankAnswers') = 'object' and not exists (
          select 1 from public.question_blanks b
          where b.question_id = v_question_id
            and btrim(coalesce(v_answer -> 'blankAnswers' ->> b.blank_key, '')) = ''
        ) then
          v_status := case
            when not exists (
              select 1 from public.question_blanks b
              where b.question_id = v_question_id
                and private.normalize_answer_text(v_answer -> 'blankAnswers' ->> b.blank_key)
                  <> private.normalize_answer_text(b.reference_answer)
            ) then 'correct'
            else 'pending_review'
          end;

          select jsonb_object_agg(b.blank_key, v_answer -> 'blankAnswers' ->> b.blank_key)
          into v_values
          from public.question_blanks b
          where b.question_id = v_question_id;

          insert into public.quiz_attempt_answers (attempt_id, question_id, blank_answers, review_status)
          values (v_attempt_id, v_question_id, v_values, v_status);
        end if;
    end case;
  end loop;

  insert into public.student_activity_days (student_id, activity_date)
  values (v_student_id, current_date)
  on conflict do nothing;

  -- QuizResult (§3.14).
  return (
    select jsonb_build_object(
      'quizId', result.quiz_id::text,
      'submittedAt', result.submitted_at,
      'correctCount', result.correct_count,
      'incorrectCount', result.incorrect_count,
      'unansweredCount', result.unanswered_count,
      'selfReviewCount', result.self_review_count,
      'scorePercent', coalesce(result.score_percent, 0),
      'subjectPerformance', coalesce(
        (
          select jsonb_agg(
            jsonb_build_object('subjectName', s.name, 'percent', performance.percent)
            order by s.name
          )
          from private.v_quiz_attempt_subject_performance performance
          join public.subjects s on s.id = performance.subject_id
          where performance.attempt_id = v_attempt_id and performance.percent is not null
        ),
        '[]'::jsonb
      ),
      'reviewItems', coalesce(
        (
          select jsonb_agg(review.item order by review.order_index)
          from (
            select
              qq.order_index,
              jsonb_strip_nulls(
                jsonb_build_object(
                  'questionId', q.id::text,
                  'subjectName', s.name,
                  'promptExcerpt', private.question_prompt_excerpt(q.type, q.prompt, q.template),
                  'status', case a.review_status when 'incorrect' then 'incorrect' else 'self_review' end,
                  'explanation', case when a.review_status = 'incorrect' then q.explanation end,
                  'studentAnswer', case
                    when a.review_status = 'pending_review' and q.type = 'essay' then btrim(a.essay_text)
                    when a.review_status = 'pending_review' then private.fill_template(q.template, a.blank_answers)
                  end,
                  'referenceAnswer', case
                    when a.review_status = 'pending_review' and q.type = 'essay' then q.reference_answer
                    when a.review_status = 'pending_review' then private.fill_template(
                      q.template,
                      (
                        select jsonb_object_agg(b.blank_key, b.reference_answer)
                        from public.question_blanks b
                        where b.question_id = q.id
                      )
                    )
                  end
                )
              ) as item
            from public.quiz_attempt_answers a
            join public.questions q on q.id = a.question_id
            join public.topics topic on topic.id = q.topic_id
            join public.subjects s on s.id = topic.subject_id
            join public.quiz_questions qq on qq.question_id = q.id and qq.quiz_id = p_quiz_id
            where a.attempt_id = v_attempt_id
              and a.review_status in ('incorrect', 'pending_review')
          ) review
        ),
        '[]'::jsonb
      )
    )
    from private.v_quiz_attempt_result result
    where result.attempt_id = v_attempt_id
  );
end;
$$;

-- =============================================================================
-- 8. Grants
-- =============================================================================

-- The app never selects from a table: every endpoint of the contract is a
-- function, so no client role needs table access at all. That is what makes the
-- policies of section 6 a second layer instead of the only barrier. The default
-- privileges revoked in section 1 already keep anon and authenticated off
-- everything created above; these revokes also cover whatever Supabase granted
-- to those roles before this migration ran.
revoke all on all tables in schema public from anon, authenticated;
revoke all on all sequences in schema public from anon, authenticated;
revoke execute on all routines in schema public from public, anon, authenticated;

-- Lets the policies of section 6 reach private.current_student_id(). Granting
-- usage on private exposes nothing on its own: PostgREST serves only the schemas
-- in [api] schemas of supabase/config.toml, and every other routine in private
-- stays unexecutable by this role.
grant usage on schema private to authenticated;
grant execute on function private.current_student_id() to authenticated;

-- The API surface, one function at a time. The squashed migrations granted
-- execute on all routines in schema public, which was correct only as long as
-- the convention "public holds nothing but endpoints" was followed by hand.
-- Naming them makes the surface an explicit allowlist instead: a helper created
-- in public by mistake is not reachable, and adding an endpoint means adding its
-- grant here on purpose.
grant execute on function public.get_current_student() to authenticated;
grant execute on function public.get_dashboard() to authenticated;
grant execute on function public.list_subjects() to authenticated;
grant execute on function public.get_subject(integer) to authenticated;
grant execute on function public.list_quizzes() to authenticated;
grant execute on function public.get_quiz(integer) to authenticated;
grant execute on function public.get_ranking() to authenticated;
grant execute on function public.submit_quiz_attempt(integer, jsonb) to authenticated;
