-- Student App — PostgreSQL schema (physical model, MVP scope)
--
-- Derived from the API contracts in docs/04-contratos-de-api.md, the domain
-- rules in docs/02-regras-de-negocio.md and the MVP acceptance criteria in
-- docs/99-criterios-de-aceite-mvp.md. The conceptual and logical models are
-- explained in docs/06-modelagem-de-dados.md.
--
-- Conventions:
--   * table-level constraints are named, so errors and future migrations can
--     reference them; column-level ones keep the predictable Postgres name;
--   * every foreign key states its ON DELETE action explicitly: CASCADE when
--     the child cannot exist without the parent, RESTRICT when deleting the
--     parent would destroy history;
--   * COMMENT ON TABLE documents each table inside the database itself;
--   * fields the API computes from other rows (counts, percentages, streak,
--     ranking position, attempt result) are views, never stored columns.
--
-- Supabase-specific changes (RLS, RPC) live in the next migration,
-- 20260916000100_auth_and_security.sql.


CREATE EXTENSION IF NOT EXISTS citext; -- case-insensitive email lookups/uniqueness

-- =============================================================================
-- 1. Enums
-- =============================================================================

-- docs/04-contratos-de-api.md §3.12 Question.type
CREATE TYPE question_type AS ENUM (
  'multiple_choice',
  'multiple_answer',
  'single_choice',
  'drag_and_drop',
  'essay',
  'essay_blanks'
);

-- docs/04-contratos-de-api.md §3.10 QuizSummary.difficulty
CREATE TYPE difficulty_level AS ENUM ('easy', 'medium', 'hard');

-- docs/04-contratos-de-api.md §3.10 QuizSummary.subjectScope
CREATE TYPE quiz_subject_scope AS ENUM ('single', 'all');

-- docs/02-regras-de-negocio.md §6. The API exposes pending_review as
-- 'self_review' (see v_quiz_review_items).
CREATE TYPE review_status AS ENUM ('correct', 'incorrect', 'pending_review');

-- =============================================================================
-- 2. Students & auth (docs/04-contratos-de-api.md §3.1, §3.2, §1.3)
-- =============================================================================

CREATE TABLE students (
  id                 INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  name               TEXT NOT NULL CHECK (btrim(name) <> ''),
  email              CITEXT NOT NULL UNIQUE,
  registration_id    TEXT NOT NULL UNIQUE CHECK (btrim(registration_id) <> ''),
  course             TEXT NOT NULL DEFAULT '',
  weekly_goal_target INTEGER NOT NULL DEFAULT 50 CHECK (weekly_goal_target > 0),
  -- Accounts are created by the institution in Supabase Auth, with public signups
  -- disabled ([auth] enable_signup = false in supabase/config.toml).
  auth_user_id       UUID NOT NULL UNIQUE REFERENCES auth.users (id) ON DELETE CASCADE
);

COMMENT ON TABLE students IS 'Pre-provisioned student accounts; there is no public signup.';
COMMENT ON COLUMN students.weekly_goal_target IS 'Weekly goal in answered questions (RankingData.profile.weeklyGoalTarget).';

-- =============================================================================
-- 3. Content: subject -> topic -> material (docs/02-regras-de-negocio.md §1)
-- =============================================================================

CREATE TABLE subjects (
  id          INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  name        TEXT NOT NULL CHECK (btrim(name) <> ''),
  short_label TEXT NOT NULL CHECK (btrim(short_label) <> '')
);

COMMENT ON TABLE subjects IS 'Course subjects (disciplinas).';

CREATE TABLE topics (
  id         INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  subject_id INTEGER NOT NULL REFERENCES subjects (id) ON DELETE CASCADE,
  name       TEXT NOT NULL CHECK (btrim(name) <> ''),
  CONSTRAINT topics_subject_id_name_key UNIQUE (subject_id, name)
);

COMMENT ON TABLE topics IS 'Topics (assuntos) of a subject; the unit used to diagnose difficulties.';

CREATE TABLE materials (
  id       INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  topic_id INTEGER NOT NULL REFERENCES topics (id) ON DELETE CASCADE,
  title    TEXT NOT NULL CHECK (btrim(title) <> ''),
  file_url TEXT NOT NULL CHECK (btrim(file_url) <> '')
);

COMMENT ON TABLE materials IS 'Study materials (PDFs) of a topic.';

CREATE INDEX idx_topics_subject_id ON topics (subject_id);
CREATE INDEX idx_materials_topic_id ON materials (topic_id);

-- =============================================================================
-- 4. Questions (docs/04-contratos-de-api.md §3.12)
-- =============================================================================

-- The subject is reached through topic_id; storing it here too would be a
-- transitive dependency.
CREATE TABLE questions (
  id               INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  topic_id         INTEGER NOT NULL REFERENCES topics (id) ON DELETE RESTRICT,
  type             question_type NOT NULL,
  prompt           TEXT, -- multiple_choice, multiple_answer, essay, essay_blanks
  template         TEXT, -- single_choice, drag_and_drop, essay_blanks ("{{id}}" placeholders)
  explanation      TEXT, -- multiple_choice, multiple_answer, single_choice, drag_and_drop
  max_length       INTEGER, -- essay
  reference_answer TEXT,    -- essay

  CONSTRAINT questions_statement_per_type_check CHECK (
    (type IN ('multiple_choice', 'multiple_answer', 'essay') AND prompt IS NOT NULL)
    OR (type IN ('single_choice', 'drag_and_drop') AND template IS NOT NULL)
    OR (type = 'essay_blanks' AND prompt IS NOT NULL AND template IS NOT NULL)
  ),
  CONSTRAINT questions_explanation_per_type_check CHECK (
    (type IN ('multiple_choice', 'multiple_answer', 'single_choice', 'drag_and_drop'))
    = (explanation IS NOT NULL)
  ),
  -- Written with IS NOT NULL on both sides: a CHECK that evaluates to NULL passes.
  CONSTRAINT questions_essay_fields_check CHECK (
    CASE
      WHEN type = 'essay'
        THEN max_length IS NOT NULL AND max_length > 0 AND reference_answer IS NOT NULL
      ELSE max_length IS NULL AND reference_answer IS NULL
    END
  )
);

COMMENT ON TABLE questions IS 'Question bank; one row per question, with the columns required by its type.';

CREATE INDEX idx_questions_topic_id ON questions (topic_id);

CREATE TABLE question_options (
  id          INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  question_id INTEGER NOT NULL REFERENCES questions (id) ON DELETE CASCADE,
  text        TEXT NOT NULL CHECK (btrim(text) <> ''),
  is_correct  BOOLEAN NOT NULL DEFAULT false,
  order_index INTEGER NOT NULL,
  CONSTRAINT question_options_question_id_order_index_key UNIQUE (question_id, order_index)
);

COMMENT ON TABLE question_options IS 'Options of multiple_choice and multiple_answer questions.';

CREATE TABLE question_blanks (
  id               INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  question_id      INTEGER NOT NULL REFERENCES questions (id) ON DELETE CASCADE,
  blank_key        TEXT NOT NULL CHECK (btrim(blank_key) <> ''),
  reference_answer TEXT, -- essay_blanks
  order_index      INTEGER NOT NULL,
  CONSTRAINT question_blanks_question_id_blank_key_key UNIQUE (question_id, blank_key)
);

COMMENT ON TABLE question_blanks IS 'Blanks of single_choice (dropdown) and essay_blanks (free text) questions; blank_key matches a {{id}} in questions.template.';

CREATE TABLE question_blank_options (
  id          INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  blank_id    INTEGER NOT NULL REFERENCES question_blanks (id) ON DELETE CASCADE,
  text        TEXT NOT NULL CHECK (btrim(text) <> ''),
  is_correct  BOOLEAN NOT NULL DEFAULT false,
  order_index INTEGER NOT NULL,
  CONSTRAINT question_blank_options_blank_id_order_index_key UNIQUE (blank_id, order_index)
);

COMMENT ON TABLE question_blank_options IS 'Dropdown options of a single_choice blank.';

CREATE TABLE question_terms (
  id          INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  question_id INTEGER NOT NULL REFERENCES questions (id) ON DELETE CASCADE,
  text        TEXT NOT NULL CHECK (btrim(text) <> ''),
  order_index INTEGER NOT NULL,
  CONSTRAINT question_terms_question_id_order_index_key UNIQUE (question_id, order_index)
);

COMMENT ON TABLE question_terms IS 'Draggable terms of a drag_and_drop question.';

CREATE TABLE question_slots (
  id              INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  question_id     INTEGER NOT NULL REFERENCES questions (id) ON DELETE CASCADE,
  slot_key        TEXT NOT NULL CHECK (btrim(slot_key) <> ''),
  correct_term_id INTEGER NOT NULL REFERENCES question_terms (id) ON DELETE CASCADE,
  order_index     INTEGER NOT NULL,
  CONSTRAINT question_slots_question_id_slot_key_key UNIQUE (question_id, slot_key)
);

COMMENT ON TABLE question_slots IS 'Drop targets of a drag_and_drop question; slot_key matches a {{id}} in questions.template.';

CREATE INDEX idx_question_options_question_id ON question_options (question_id);
CREATE INDEX idx_question_blanks_question_id ON question_blanks (question_id);
CREATE INDEX idx_question_blank_options_blank_id ON question_blank_options (blank_id);
CREATE INDEX idx_question_terms_question_id ON question_terms (question_id);
CREATE INDEX idx_question_slots_question_id ON question_slots (question_id);
CREATE INDEX idx_question_slots_correct_term_id ON question_slots (correct_term_id);

-- =============================================================================
-- 5. Quizzes and exams (docs/04-contratos-de-api.md §3.5, §3.10, §3.11)
-- =============================================================================

-- There is no attempt limit: QuizSummary.attemptsCount reports how many
-- attempts the student has already submitted (see v_student_quiz_attempts).
CREATE TABLE quizzes (
  id               INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  title            TEXT NOT NULL CHECK (btrim(title) <> ''),
  subject_scope    quiz_subject_scope NOT NULL,
  subject_id       INTEGER REFERENCES subjects (id) ON DELETE RESTRICT,
  duration_minutes INTEGER NOT NULL CHECK (duration_minutes > 0),
  difficulty       difficulty_level NOT NULL,

  CONSTRAINT quizzes_subject_scope_check CHECK ((subject_scope = 'single') = (subject_id IS NOT NULL))
);

COMMENT ON TABLE quizzes IS 'Quizzes (simulados); subject_id is set only when subject_scope is single.';

CREATE TABLE quiz_questions (
  quiz_id     INTEGER NOT NULL REFERENCES quizzes (id) ON DELETE CASCADE,
  question_id INTEGER NOT NULL REFERENCES questions (id) ON DELETE RESTRICT,
  order_index INTEGER NOT NULL,
  CONSTRAINT quiz_questions_pkey PRIMARY KEY (quiz_id, question_id),
  CONSTRAINT quiz_questions_quiz_id_order_index_key UNIQUE (quiz_id, order_index)
);

COMMENT ON TABLE quiz_questions IS 'Questions of a quiz, in display order.';

CREATE INDEX idx_quiz_questions_question_id ON quiz_questions (question_id);

CREATE TABLE scheduled_exams (
  id         INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  subject_id INTEGER NOT NULL REFERENCES subjects (id) ON DELETE CASCADE,
  exam_date  DATE NOT NULL,
  note       TEXT NOT NULL DEFAULT ''
);

COMMENT ON TABLE scheduled_exams IS 'Upcoming exams; backs DashboardData.nextExam.';

CREATE INDEX idx_scheduled_exams_subject_id ON scheduled_exams (subject_id);

-- =============================================================================
-- 6. Attempts (docs/04-contratos-de-api.md §3.13, §3.14)
-- =============================================================================

-- The current contract creates an attempt only when it is submitted, so every
-- row here is one submitted attempt.
CREATE TABLE quiz_attempts (
  id           INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  quiz_id      INTEGER NOT NULL REFERENCES quizzes (id) ON DELETE RESTRICT,
  student_id   INTEGER NOT NULL REFERENCES students (id) ON DELETE CASCADE,
  submitted_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

COMMENT ON TABLE quiz_attempts IS 'One row per submitted attempt; counted by QuizSummary.attemptsCount.';

CREATE INDEX idx_quiz_attempts_student_id ON quiz_attempts (student_id);
CREATE INDEX idx_quiz_attempts_quiz_id ON quiz_attempts (quiz_id);

-- Only answered questions are stored: the client does not send questions left
-- blank or partially filled, and they count as unanswered in the result.
CREATE TABLE quiz_attempt_answers (
  id                  INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  attempt_id          INTEGER NOT NULL REFERENCES quiz_attempts (id) ON DELETE CASCADE,
  question_id         INTEGER NOT NULL REFERENCES questions (id) ON DELETE RESTRICT,
  selected_option_id  INTEGER REFERENCES question_options (id) ON DELETE RESTRICT, -- multiple_choice
  selected_option_ids JSONB, -- multiple_answer: option ids
  essay_text          TEXT,  -- essay
  blank_answers       JSONB, -- single_choice / essay_blanks: {blankKey: value}
  slot_answers        JSONB, -- drag_and_drop: {slotKey: termId}
  review_status       review_status NOT NULL,

  CONSTRAINT quiz_attempt_answers_attempt_id_question_id_key UNIQUE (attempt_id, question_id)
);

COMMENT ON TABLE quiz_attempt_answers IS 'One row per answered question; only the column matching the question type is filled.';

CREATE INDEX idx_quiz_attempt_answers_question_id ON quiz_attempt_answers (question_id);

-- =============================================================================
-- 7. Gamification (docs/02-regras-de-negocio.md §11 — never based on grades)
-- =============================================================================

CREATE TABLE student_activity_days (
  student_id    INTEGER NOT NULL REFERENCES students (id) ON DELETE CASCADE,
  activity_date DATE NOT NULL,
  CONSTRAINT student_activity_days_pkey PRIMARY KEY (student_id, activity_date)
);

COMMENT ON TABLE student_activity_days IS 'One row per day the student studied; source of the streak.';

-- =============================================================================
-- 8. Views — derived fields
-- =============================================================================

-- Subject.materialsCount / questionsCount (§3.9).
CREATE VIEW v_subject_summary AS
SELECT
  s.id AS subject_id,
  (SELECT COUNT(*) FROM materials m JOIN topics t ON t.id = m.topic_id WHERE t.subject_id = s.id) AS materials_count,
  (SELECT COUNT(*) FROM questions q JOIN topics t ON t.id = q.topic_id WHERE t.subject_id = s.id) AS questions_count
FROM subjects s;

-- Subject.preparationPercent (§3.9) and NextExam.overallPreparation (§3.5).
CREATE VIEW v_student_subject_performance AS
SELECT
  qa.student_id,
  t.subject_id,
  ROUND(
    100.0 * COUNT(*) FILTER (WHERE qaa.review_status = 'correct')
      / NULLIF(COUNT(*) FILTER (WHERE qaa.review_status <> 'pending_review'), 0),
    2
  ) AS preparation_percent
FROM quiz_attempt_answers qaa
JOIN quiz_attempts qa ON qa.id = qaa.attempt_id
JOIN questions q ON q.id = qaa.question_id
JOIN topics t ON t.id = q.topic_id
GROUP BY qa.student_id, t.subject_id;

-- Source for NextExam.priorities (§3.6); the high/medium/low level is a
-- threshold applied by the application.
CREATE VIEW v_student_topic_performance AS
SELECT
  qa.student_id,
  q.topic_id,
  COUNT(*) FILTER (WHERE qaa.review_status <> 'pending_review') AS graded_count,
  ROUND(
    100.0 * COUNT(*) FILTER (WHERE qaa.review_status = 'correct')
      / NULLIF(COUNT(*) FILTER (WHERE qaa.review_status <> 'pending_review'), 0),
    2
  ) AS percent
FROM quiz_attempt_answers qaa
JOIN quiz_attempts qa ON qa.id = qaa.attempt_id
JOIN questions q ON q.id = qaa.question_id
GROUP BY qa.student_id, q.topic_id;

-- QuizSummary.questionCount (§3.10).
CREATE VIEW v_quiz_summary AS
SELECT
  quiz.id AS quiz_id,
  COUNT(qq.question_id) AS question_count
FROM quizzes quiz
LEFT JOIN quiz_questions qq ON qq.quiz_id = quiz.id
GROUP BY quiz.id;

-- QuizSummary.attemptsCount (§3.10): attempts the student already submitted.
CREATE VIEW v_student_quiz_attempts AS
SELECT
  quiz.id AS quiz_id,
  s.id AS student_id,
  COUNT(qa.id) AS attempts_count
FROM quizzes quiz
CROSS JOIN students s
LEFT JOIN quiz_attempts qa ON qa.quiz_id = quiz.id AND qa.student_id = s.id
GROUP BY quiz.id, s.id;

-- QuizResult counters and scorePercent (§3.14). pending_review answers are
-- left out of the score; unanswered questions count in the denominator.
CREATE VIEW v_quiz_attempt_result AS
SELECT
  qa.id AS attempt_id,
  qa.quiz_id,
  qa.submitted_at,
  COUNT(*) FILTER (WHERE qaa.review_status = 'correct') AS correct_count,
  COUNT(*) FILTER (WHERE qaa.review_status = 'incorrect') AS incorrect_count,
  COUNT(*) FILTER (WHERE qaa.id IS NULL) AS unanswered_count,
  COUNT(*) FILTER (WHERE qaa.review_status = 'pending_review') AS self_review_count,
  ROUND(
    100.0 * COUNT(*) FILTER (WHERE qaa.review_status = 'correct')
      / NULLIF(COUNT(*) FILTER (WHERE qaa.review_status IS DISTINCT FROM 'pending_review'), 0),
    2
  ) AS score_percent
FROM quiz_attempts qa
JOIN quiz_questions qq ON qq.quiz_id = qa.quiz_id
LEFT JOIN quiz_attempt_answers qaa ON qaa.attempt_id = qa.id AND qaa.question_id = qq.question_id
GROUP BY qa.id;

-- QuizResult.subjectPerformance (§3.14), same rules as score_percent.
CREATE VIEW v_quiz_attempt_subject_performance AS
SELECT
  qa.id AS attempt_id,
  t.subject_id,
  ROUND(
    100.0 * COUNT(*) FILTER (WHERE qaa.review_status = 'correct')
      / NULLIF(COUNT(*) FILTER (WHERE qaa.review_status IS DISTINCT FROM 'pending_review'), 0),
    2
  ) AS percent
FROM quiz_attempts qa
JOIN quiz_questions qq ON qq.quiz_id = qa.quiz_id
JOIN questions q ON q.id = qq.question_id
JOIN topics t ON t.id = q.topic_id
LEFT JOIN quiz_attempt_answers qaa ON qaa.attempt_id = qa.id AND qaa.question_id = qq.question_id
GROUP BY qa.id, t.subject_id;

-- QuizResult.reviewItems (§3.14).
CREATE VIEW v_quiz_review_items AS
SELECT
  qaa.attempt_id,
  qaa.question_id,
  t.subject_id,
  CASE qaa.review_status
    WHEN 'incorrect' THEN 'incorrect'
    WHEN 'pending_review' THEN 'self_review'
  END AS status,
  q.explanation,
  q.reference_answer,
  qaa.essay_text AS student_answer
FROM quiz_attempt_answers qaa
JOIN questions q ON q.id = qaa.question_id
JOIN topics t ON t.id = q.topic_id
WHERE qaa.review_status IN ('incorrect', 'pending_review');

-- streakDays: consecutive activity days ending today or yesterday.
CREATE VIEW v_student_streak AS
WITH islands AS (
  SELECT
    student_id,
    activity_date,
    activity_date - (ROW_NUMBER() OVER (PARTITION BY student_id ORDER BY activity_date))::int AS island
  FROM student_activity_days
),
runs AS (
  SELECT student_id, MAX(activity_date) AS run_end, COUNT(*) AS run_length
  FROM islands
  GROUP BY student_id, island
)
SELECT DISTINCT ON (student_id)
  student_id,
  run_length AS streak_days
FROM runs
WHERE run_end >= CURRENT_DATE - 1
ORDER BY student_id, run_end DESC;

-- RankingData.entries (§3.15).
CREATE VIEW v_student_ranking AS
SELECT
  s.id AS student_id,
  s.name AS student_name,
  COALESCE(st.streak_days, 0) AS streak_days,
  RANK() OVER (ORDER BY COALESCE(st.streak_days, 0) DESC, s.name ASC) AS position
FROM students s
LEFT JOIN v_student_streak st ON st.student_id = s.id;

-- RankingData.profile (§3.15).
CREATE VIEW v_student_ranking_profile AS
SELECT
  s.id AS student_id,
  COALESCE(st.streak_days, 0) AS streak_days,
  s.weekly_goal_target,
  (
    SELECT COUNT(*)
    FROM quiz_attempt_answers qaa
    JOIN quiz_attempts qa ON qa.id = qaa.attempt_id
    WHERE qa.student_id = s.id AND qa.submitted_at >= date_trunc('week', now())
  ) AS weekly_goal_completed,
  (
    SELECT COUNT(*)
    FROM quiz_attempt_answers qaa
    JOIN quiz_attempts qa ON qa.id = qaa.attempt_id
    WHERE qa.student_id = s.id
  ) AS questions_answered,
  (SELECT COUNT(*) FROM quiz_attempts qa WHERE qa.student_id = s.id) AS quizzes_completed
FROM students s
LEFT JOIN v_student_streak st ON st.student_id = s.id;

