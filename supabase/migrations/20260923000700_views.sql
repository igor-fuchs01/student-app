-- Student App — views: derived fields (private: reachable only through the functions).

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

-- RankingData.entries (§3.15). Students tied on streak share a position.
create view private.v_student_ranking as
select
  s.id as student_id,
  coalesce(st.streak_days, 0) as streak_days,
  rank() over (order by coalesce(st.streak_days, 0) desc) as position
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
