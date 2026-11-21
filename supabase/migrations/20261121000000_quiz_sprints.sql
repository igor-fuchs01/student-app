-- Student App — semester of a subject and sprints of a simulado
-- (docs/02-regras-de-negocio.md §3, docs/04-contratos-de-api.md GET /quizzes).
--
-- A simulado usually covers one sprint, but a review simulado can cover more
-- than one (e.g. "Sprint 1 e 2"), so the sprints are rows of their own instead
-- of a column of quizzes. Only simulados (kind exam) get sprints; exercise
-- lists already belong to one assunto. The semester is the subject's: every
-- simulado of a subject is of the same semester.

alter table subjects
  add column semester smallint not null default 1,
  add constraint subjects_semester_check check (semester between 1 and 5);

comment on column subjects.semester is 'Semester of the course the subject is taught in (1 to 5); QuizSummary.semester.';

create table quiz_sprints (
  quiz_id integer not null references quizzes (id) on delete cascade,
  sprint  smallint not null,
  constraint quiz_sprints_pkey primary key (quiz_id, sprint),
  constraint quiz_sprints_sprint_check check (sprint between 1 and 3)
);

comment on table quiz_sprints is 'Sprints (1 to 3) whose content a simulado covers; QuizSummary.sprints.';

alter table public.quiz_sprints enable row level security;

create policy "signed-in students read quiz sprints"
  on public.quiz_sprints for select to authenticated using (true);
