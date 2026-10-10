-- Student App — administrators and the audit log of what they write
-- (docs/04-contratos-de-api.md, "Administração").

-- Who may call the admin-* edge functions. The role lives here, never in the
-- JWT or in user metadata: serveAdminEndpoint (supabase/functions/_shared/http.ts)
-- looks the account up on every request, so deleting the row revokes the access
-- at once, even while the token is still valid. An admin account is created by
-- hand, with the e-mail <code>@admin.student-app.invalid, and is never a student.
create table admins (
  id           integer generated always as identity primary key,
  auth_user_id uuid not null unique references auth.users (id) on delete cascade,
  created_at   timestamptz not null default now()
);

comment on table admins is 'Auth accounts allowed to call the admin-* edge functions; created by hand, never through the API.';

-- One row per write of an admin, in the same transaction as the write.
-- admin_auth_user_id has no foreign key on purpose: the log outlives the admin.
create table admin_audit_log (
  id                 integer generated always as identity primary key,
  admin_auth_user_id uuid not null,
  action             text not null,
  entity             text not null check (btrim(entity) <> ''),
  entity_id          integer,
  created_at         timestamptz not null default now(),
  constraint admin_audit_log_action_check check (action in ('create', 'update', 'delete', 'import'))
);

comment on table admin_audit_log is 'Who created, updated, deleted or imported what through the admin-* edge functions.';
comment on column admin_audit_log.entity is 'Table the write targeted (subjects, topics, subtopics, questions, quizzes).';

create index idx_admin_audit_log_created_at on admin_audit_log (created_at);

-- Only the edge functions read or write them, through their direct connection:
-- no policy, so the Data API roles never see who the admins are.
alter table public.admins enable row level security;
alter table public.admin_audit_log enable row level security;
revoke all on table public.admins, public.admin_audit_log from anon, authenticated;
