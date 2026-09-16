-- Student App — empties every table filled by seed.sql.
--
--   psql "$DATABASE_URL" -f database/reset.sql
--
-- TRUNCATE removes all rows and RESTART IDENTITY puts the id sequences back to
-- 1, so seeding again produces the same ids. CASCADE only reaches tables that
-- reference the ones listed, and all of them are already in the list.
--
-- This deletes data but keeps the structure. To drop the structure too, drop
-- the database (or the tables) and run schema.sql again.

BEGIN;

TRUNCATE TABLE
  quiz_attempt_answers,
  quiz_attempts,
  quiz_questions,
  question_slots,
  question_terms,
  question_blank_options,
  question_blanks,
  question_options,
  questions,
  materials,
  topics,
  scheduled_exams,
  quizzes,
  subjects,
  student_activity_days,
  auth_tokens,
  students
RESTART IDENTITY CASCADE;

COMMIT;
