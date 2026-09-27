-- Student App — attempts (docs/04-contratos-de-api.md §3.13, §3.14) and
-- gamification (docs/02-regras-de-negocio.md §11 — never based on grades).

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

create table student_activity_days (
  student_id    integer not null references students (id) on delete cascade,
  activity_date date not null,
  constraint student_activity_days_pkey primary key (student_id, activity_date)
);

comment on table student_activity_days is 'One row per day the student studied; source of the streak.';

create index idx_quiz_attempts_student_id on quiz_attempts (student_id);
create index idx_quiz_attempts_quiz_id on quiz_attempts (quiz_id);
create index idx_quiz_attempt_answers_question_id on quiz_attempt_answers (question_id);
