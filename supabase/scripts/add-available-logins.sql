-- Student App — creates random access codes a student can claim on the first
-- access, choosing their own password (POST /auth/register, the temporary
-- register-student edge function). It is an operator tool, not part of the API.
--
-- How to use it: set how many codes to create in generate_series(1, 30) below,
-- then run this whole file — in the Supabase Studio SQL editor
-- (http://127.0.0.1:54323 locally, or the project's SQL editor in production),
-- or with psql:
--
--   psql "postgresql://postgres:postgres@127.0.0.1:54322/postgres" \
--     -f supabase/scripts/add-available-logins.sql
--
-- The result lists the new codes: hand one to each student. Already created
-- codes, and the account each one became, are always in available_logins:
--
--   select access_code, claimed_at, auth_user_id from available_logins order by created_at;
--
-- How it works:
--   * whoever types an available code first gets its account, so the codes
--     are random: 10 characters from a 32-character alphabet (50 bits) taken
--     from gen_random_uuid, which uses a cryptographic random source;
--   * the alphabet leaves out i, l and 0, 1, which are easy to mix up when
--     the code is read aloud or copied by hand. 256 is a multiple of 32, so
--     every character is equally likely;
--   * a repeated code, practically impossible, is skipped instead of failing,
--     so the result may list fewer codes than asked.

INSERT INTO available_logins (access_code)
SELECT string_agg(
  substr('abcdefghjkmnopqrstuvwxyz23456789', 1 + get_byte(uuid_send(gen_random_uuid()), 0) % 32, 1),
  '' ORDER BY position
)
FROM generate_series(1, 30) AS login(number)
CROSS JOIN generate_series(1, 10) AS code(position)
GROUP BY number
ON CONFLICT (access_code) DO NOTHING
RETURNING access_code;
