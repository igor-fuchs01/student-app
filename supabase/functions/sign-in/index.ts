import "@supabase/functions-js/edge-runtime.d.ts";
import { withSupabase } from "@supabase/server";

// Supabase Auth signs in by email, but students may type their registration id (matrícula).
// The lookup runs here with the service role, so no client ever reads another student's email.

function jsonError(status: number, code: string, message: string): Response {
  return Response.json({ code, message }, { status });
}

// Same answer for an unknown registration id and a wrong password, so accounts can't be probed.
function invalidCredentials(): Response {
  return jsonError(401, "INVALID_CREDENTIALS", "Matrícula/e-mail ou senha inválidos.");
}

export default {
  fetch: withSupabase({ auth: "publishable" }, async (req, ctx) => {
    if (req.method !== "POST") {
      return jsonError(404, "NOT_FOUND", "Recurso não encontrado.");
    }

    const body = await req.json().catch(() => null);
    const identifier = typeof body?.identifier === "string" ? body.identifier.trim() : "";
    const password = typeof body?.password === "string" ? body.password : "";
    if (!identifier || !password) {
      return jsonError(400, "VALIDATION_ERROR", "Informe matrícula/e-mail e senha.");
    }

    let email = identifier;
    if (!identifier.includes("@")) {
      const { data: student } = await ctx.supabaseAdmin
        .from("students")
        .select("email")
        .eq("registration_id", identifier)
        .maybeSingle();
      if (!student) return invalidCredentials();
      email = student.email;
    }

    const { data, error } = await ctx.supabase.auth.signInWithPassword({ email, password });
    if (error || !data.session) return invalidCredentials();

    return Response.json({
      accessToken: data.session.access_token,
      refreshToken: data.session.refresh_token,
    });
  }),
};
