-- Student App — enums.

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
