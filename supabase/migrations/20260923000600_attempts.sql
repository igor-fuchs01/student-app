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
-- blank or partially filled, and they count as unanswered in the result. A
-- single-valued answer lives in its own column (only the one matching the
-- question type is filled); answers with several values go to the child
-- tables below, one row per value, so no answer is stored as json.
create table quiz_attempt_answers (
  id                 integer generated always as identity primary key,
  attempt_id         integer not null references quiz_attempts (id) on delete cascade,
  question_id        integer not null references questions (id) on delete restrict,
  selected_option_id integer references question_options (id) on delete restrict, -- multiple_choice
  essay_text         text, -- essay
  review_status      review_status not null,

  constraint quiz_attempt_answers_attempt_id_question_id_key unique (attempt_id, question_id)
);

comment on table quiz_attempt_answers is 'One row per answered question; multiple_choice and essay keep their value here, the other types in the quiz_attempt_answer_* tables.';

create table quiz_attempt_answer_options (
  answer_id integer not null references quiz_attempt_answers (id) on delete cascade,
  option_id integer not null references question_options (id) on delete restrict,
  constraint quiz_attempt_answer_options_pkey primary key (answer_id, option_id)
);

comment on table quiz_attempt_answer_options is 'Options selected in a multiple_answer answer.';

create table quiz_attempt_answer_blanks (
  answer_id          integer not null references quiz_attempt_answers (id) on delete cascade,
  blank_id           integer not null references question_blanks (id) on delete restrict,
  selected_option_id integer references question_blank_options (id) on delete restrict, -- single_choice
  text               text, -- essay_blanks
  constraint quiz_attempt_answer_blanks_pkey primary key (answer_id, blank_id),
  constraint quiz_attempt_answer_blanks_value_check check ((selected_option_id is null) <> (text is null))
);

comment on table quiz_attempt_answer_blanks is 'One row per blank of a single_choice (the chosen option) or essay_blanks (the typed text) answer.';

create table quiz_attempt_answer_slots (
  answer_id integer not null references quiz_attempt_answers (id) on delete cascade,
  slot_id   integer not null references question_slots (id) on delete restrict,
  term_id   integer not null references question_terms (id) on delete restrict,
  constraint quiz_attempt_answer_slots_pkey primary key (answer_id, slot_id)
);

comment on table quiz_attempt_answer_slots is 'One row per slot of a drag_and_drop answer, with the term dropped on it.';

create table student_activity_days (
  student_id    integer not null references students (id) on delete cascade,
  activity_date date not null,
  constraint student_activity_days_pkey primary key (student_id, activity_date)
);

comment on table student_activity_days is 'One row per day the student studied; source of the streak.';

create index idx_quiz_attempts_student_id on quiz_attempts (student_id);
create index idx_quiz_attempts_quiz_id on quiz_attempts (quiz_id);
create index idx_quiz_attempt_answers_question_id on quiz_attempt_answers (question_id);
create index idx_quiz_attempt_answers_selected_option_id on quiz_attempt_answers (selected_option_id);
create index idx_quiz_attempt_answer_options_option_id on quiz_attempt_answer_options (option_id);
create index idx_quiz_attempt_answer_blanks_blank_id on quiz_attempt_answer_blanks (blank_id);
create index idx_quiz_attempt_answer_blanks_selected_option_id on quiz_attempt_answer_blanks (selected_option_id);
create index idx_quiz_attempt_answer_slots_slot_id on quiz_attempt_answer_slots (slot_id);
create index idx_quiz_attempt_answer_slots_term_id on quiz_attempt_answer_slots (term_id);
