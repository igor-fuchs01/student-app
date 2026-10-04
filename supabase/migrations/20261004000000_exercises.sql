-- Student App — exercise lists (docs/02-regras-de-negocio.md §3,
-- docs/04-contratos-de-api.md GET /exercises).
--
-- An exercise list is a quiz of one assunto with no time limit, so it reuses
-- quiz_questions, quiz_attempts, the grading and the result. Its answers count
-- in every statistic except the number of simulados completed.

create type quiz_kind as enum ('exam', 'exercise');

alter table quizzes
  add column kind quiz_kind not null default 'exam',
  add column topic_id integer references topics (id) on delete restrict,
  alter column duration_minutes drop not null,
  add constraint quizzes_kind_topic_check check ((kind = 'exercise') = (topic_id is not null)),
  add constraint quizzes_kind_duration_check check ((kind = 'exercise') = (duration_minutes is null)),
  add constraint quizzes_kind_subject_scope_check check (kind = 'exam' or subject_scope = 'single');

comment on column quizzes.kind is 'exam: a simulado, listed by GET /quizzes; exercise: an exercise list of one assunto, listed by GET /exercises.';
comment on column quizzes.topic_id is 'Assunto of an exercise list; subject_id is that assunto''s subject (set by supabase/scripts/import-quiz.sql).';
comment on column quizzes.duration_minutes is 'Time limit of a simulado; null for an exercise list, which has none.';

create index idx_quizzes_topic_id on quizzes (topic_id);

-- RankingData.profile (§3.15): quizzesCompleted counts simulados only.
create or replace view private.v_student_ranking_profile as
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
  (
    select count(*)
    from quiz_attempts qa
    join quizzes z on z.id = qa.quiz_id
    where qa.student_id = s.id and z.kind = 'exam'
  ) as quizzes_completed
from students s
left join private.v_student_streak st on st.student_id = s.id;
