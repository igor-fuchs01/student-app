-- Student App — drop what only the old home screen read.

-- The home screen no longer shows the next exam with its topic priorities
-- (docs/04-contratos-de-api.md §3.4): get-dashboard now computes the
-- performance per period itself, and nothing else read these. The table's
-- index and row level security policy go with it.
drop view private.v_student_topic_performance;
drop table scheduled_exams;
