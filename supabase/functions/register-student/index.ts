// POST register-student: creates the account of an access code from available_logins, with the
// password the student chose, and returns a RegisterResult (docs/04-contratos-de-api.md, POST
// /auth/register). Temporary: it stands in for the institution's provisioning while accounts are
// not created with a password; it is the only endpoint that takes no JWT.
//
// The code is claimed, the Auth account created, and the students row and the code's link to the
// account written inside one transaction. A second request for the same code waits on the row
// lock and then finds it claimed, so each code gets a single account; any failure leaves the code
// available.
import { createClient } from "npm:@supabase/supabase-js@2";
import { z } from "npm:zod@4";
import { sql } from "../_shared/db.ts";
import { ApiError, servePublicEndpoint } from "../_shared/http.ts";

// Same e-mail the app signs in with (src/services/api/supabase/authApi.ts).
const ACCESS_CODE_EMAIL_DOMAIN = "alunos.student-app.invalid";
const COURSE = "Análise e Desenvolvimento de Sistemas";

// Same rules as registerCredentialsSchema in src/types/auth.ts. 72 bytes is the most bcrypt
// reads, so a longer password would be silently cut.
const bodySchema = z.object({
  accessCode: z
    .string()
    .trim()
    .toLowerCase()
    .regex(/^[a-z0-9]{6,32}$/),
  password: z.string().min(6).max(72),
});

const admin = createClient(
  Deno.env.get("SUPABASE_URL")!,
  Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!,
  { auth: { persistSession: false, autoRefreshToken: false } },
);

// Same answer for an unknown code and one already claimed, so codes can't be probed.
function unavailable(): ApiError {
  return new ApiError(
    404,
    "NOT_FOUND",
    "Este código de acesso não está disponível. Se você já criou sua senha, entre com ela.",
  );
}

function invalidBody(): ApiError {
  return new ApiError(
    400,
    "VALIDATION_ERROR",
    "Informe um código de acesso válido e uma senha de 6 a 72 caracteres.",
  );
}

servePublicEndpoint("POST", async ({ request }) => {
  const body = bodySchema.safeParse(await request.json().catch(() => null));
  if (!body.success) throw invalidBody();
  const { accessCode, password } = body.data;

  await sql.begin(async (tx) => {
    const [login] = await tx<{ access_code: string }[]>`
      update available_logins set claimed_at = now()
      where access_code = ${accessCode} and claimed_at is null
      returning access_code
    `;
    if (!login) throw unavailable();

    const { data, error } = await admin.auth.admin.createUser({
      email: `${accessCode}@${ACCESS_CODE_EMAIL_DOMAIN}`,
      password,
      email_confirm: true,
    });
    if (error) {
      if (error.code === "weak_password") throw invalidBody();
      if (error.code === "email_exists" || error.code === "user_already_exists") {
        throw unavailable();
      }
      throw error;
    }

    try {
      await tx`insert into students (course, auth_user_id) values (${COURSE}, ${data.user.id})`;
      await tx`
        update available_logins set auth_user_id = ${data.user.id}
        where access_code = ${accessCode}
      `;
    } catch (insertError) {
      await admin.auth.admin.deleteUser(data.user.id);
      throw insertError;
    }
  });

  return { accessCode };
});
