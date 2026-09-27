-- Student App — quizzes and exams (docs/04-contratos-de-api.md §3.5, §3.10, §3.11).

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

create index idx_quiz_questions_question_id on quiz_questions (question_id);
create index idx_scheduled_exams_subject_id on scheduled_exams (subject_id);
