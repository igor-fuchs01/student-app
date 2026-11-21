-- Student App — days and weeks in Brasília time (docs/02-regras-de-negocio.md
-- §11).
--
-- The database runs in UTC, so current_date and a timestamptz cast to date
-- turned the day at 21:00 in Brasília: a study session on Monday night was
-- recorded as Tuesday and could break the streak. Every day and week of the app
-- (study days, streak, weekly goal, dashboard periods and activity calendar) is
-- now the date in America/Sao_Paulo, and private.local_date is the only place
-- that names the time zone. The views keep exactly the same columns.

-- The date of a moment in Brasília; private.local_date(now()) is today.
create function private.local_date(p_at timestamptz)
returns date
language sql
stable
set search_path = ''
as $$
  select (p_at at time zone 'America/Sao_Paulo')::date
$$;

-- streakDays: consecutive activity days ending today or yesterday.
create or replace view private.v_student_streak as
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
where run_end >= private.local_date(now()) - 1
order by student_id, run_end desc;

-- RankingData.profile (§3.15): the weekly goal counts the answers since Monday.
create or replace view private.v_student_ranking_profile as
select
  s.id as student_id,
  coalesce(st.streak_days, 0) as streak_days,
  s.weekly_goal_target,
  (
    select count(*)
    from quiz_attempt_answers qaa
    join quiz_attempts qa on qa.id = qaa.attempt_id
    where qa.student_id = s.id
      and private.local_date(qa.submitted_at)
        >= date_trunc('week', private.local_date(now())::timestamp)::date
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
