-- Student App — drop the integrated simulado (docs/04-contratos-de-api.md
-- §3.10): every quiz now belongs to one subject, so subject_scope and its enum
-- go away and subject_id becomes required.
--
-- A quiz without a subject would be lost silently, so the migration refuses to
-- run while one exists; delete or reassign it first.
do $$
begin
  if exists (select 1 from quizzes where subject_id is null) then
    raise exception 'integrated quizzes (subject_id is null) still exist; delete or reassign them before this migration';
  end if;
end
$$;

alter table quizzes
  drop constraint quizzes_subject_scope_check,
  drop constraint quizzes_kind_subject_scope_check,
  drop column subject_scope,
  alter column subject_id set not null;

drop type quiz_subject_scope;

comment on table quizzes is 'Quizzes of one subject: simulados (kind exam) and exercise lists of one of its topics (kind exercise).';
