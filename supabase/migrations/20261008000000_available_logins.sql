-- Student App — logins handed out before their account exists (temporary).

-- The operator registers random access codes here by hand
-- (supabase/scripts/add-available-logins.sql); a student then creates the
-- account of one of them, with a password of their own, through the
-- register-student edge function (docs/04-contratos-de-api.md, POST
-- /auth/register). A code can be claimed only once. This stands in for the
-- institution's provisioning while accounts are not created with a password.
create table available_logins (
  access_code text primary key check (access_code ~ '^[a-z0-9]{6,32}$'),
  created_at  timestamptz not null default now(),
  claimed_at  timestamptz,
  -- Set null, not cascade, when the account is deleted: the code stays claimed, so it is never
  -- handed to a second student.
  auth_user_id uuid unique references auth.users (id) on delete set null
);

comment on table available_logins is 'Access codes a student may claim once, choosing the password; temporary first-access flow.';
comment on column available_logins.claimed_at is 'When the account was created; null while the code is still available.';
comment on column available_logins.auth_user_id is 'The Auth account created from this code, which students.auth_user_id also points to.';

-- Only the edge function reads it, through its direct connection: no policy,
-- so the Data API roles never see a code that is still available.
alter table public.available_logins enable row level security;
revoke all on table public.available_logins from anon, authenticated;
