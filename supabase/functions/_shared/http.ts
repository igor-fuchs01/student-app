import { createClient } from "npm:@supabase/supabase-js@2";
import { corsHeaders, handlePreflight } from "./cors.ts";
import { sql } from "./db.ts";

// An error the client is meant to see: the status and the contract's { code, message } body
// (docs/04-contratos-de-api.md, section 4), with a Portuguese message for the student.
export class ApiError extends Error {
  constructor(
    readonly status: number,
    readonly code: string,
    message: string,
  ) {
    super(message);
  }
}

type EndpointContext = {
  request: Request;
  url: URL;
  studentId: number;
};

const supabase = createClient(Deno.env.get("SUPABASE_URL")!, Deno.env.get("SUPABASE_ANON_KEY")!, {
  auth: { persistSession: false, autoRefreshToken: false },
});

// The student of the request's JWT. The gateway does not verify it (verify_jwt = false in
// supabase/config.toml, so the CORS preflight gets through), so every endpoint does it here.
async function requireStudentId(request: Request): Promise<number> {
  const token = request.headers.get("Authorization")?.replace(/^Bearer /, "") ?? "";
  // getClaims throws instead of returning an error for some malformed tokens (payload that isn't
  // JSON, unsupported alg), which would otherwise reach the 500 below and keep the student logged in.
  const { data } = token
    ? await supabase.auth.getClaims(token).catch(() => ({ data: null }))
    : { data: null };
  const authUserId = data?.claims.sub;

  if (authUserId) {
    const [student] = await sql<{ id: number }[]>`
      select id from students where auth_user_id = ${authUserId}
    `;
    if (student) return student.id;
  }
  throw new ApiError(401, "UNAUTHORIZED", "Sessão expirada. Faça login novamente.");
}

// Serves one endpoint: CORS, the method and the error body.
function serve(method: "GET" | "POST", handle: (request: Request) => Promise<unknown>): void {
  Deno.serve(async (request) => {
    const preflight = handlePreflight(request);
    if (preflight) return preflight;

    const headers = { ...corsHeaders(request), "Content-Type": "application/json" };
    const reply = (status: number, body: unknown) =>
      new Response(JSON.stringify(body), { status, headers });

    if (request.method !== method) {
      return reply(405, { code: "METHOD_NOT_ALLOWED", message: "Método não permitido." });
    }

    try {
      return reply(200, await handle(request));
    } catch (error) {
      if (error instanceof ApiError) {
        return reply(error.status, { code: error.code, message: error.message });
      }
      console.error(error);
      return reply(500, {
        code: "UNKNOWN_ERROR",
        message: "Ocorreu um erro inesperado. Tente novamente.",
      });
    }
  });
}

// Serves one authenticated endpoint: the student comes from the request's JWT.
export function serveEndpoint(
  method: "GET" | "POST",
  handler: (context: EndpointContext) => Promise<unknown>,
): void {
  serve(method, async (request) => {
    const studentId = await requireStudentId(request);
    return handler({ request, url: new URL(request.url), studentId });
  });
}

// Serves one endpoint that takes no JWT; only register-student, which runs before the account
// exists.
export function servePublicEndpoint(
  method: "GET" | "POST",
  handler: (context: Omit<EndpointContext, "studentId">) => Promise<unknown>,
): void {
  serve(method, (request) => handler({ request, url: new URL(request.url) }));
}
