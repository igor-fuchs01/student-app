// POST submit-quiz-attempt (docs/04-contratos-de-api.md, POST /quizzes/:id/attempts): grades a quiz
// attempt and returns its QuizResult.
//
// This function owns the request: CORS, the student's JWT and the shape of the
// body, validated with zod. Grading stays in the database function
// public.submit_quiz_attempt, which runs every insert in one transaction and
// may be executed only by service_role, so the RPC is reachable through here
// and nowhere else.
import { createClient } from "@supabase/supabase-js";
import { z } from "zod";
import { corsHeaders, handlePreflight } from "../_shared/cors.ts";

// Database ids travel as numeric strings; nine digits always fit an integer.
const id = z.string().regex(/^\d{1,9}$/);
// An empty value is a blank the student left unanswered; the grading counts it
// as such instead of rejecting it.
const idOrEmpty = z.string().regex(/^\d{0,9}$/);

// Same fields as quizAnswerSchema in src/types/quizzes.ts, with the bounds the
// server needs. The texts are safety ceilings, not rules the student is meant
// to feel: an essay is also held to its own questions.max_length.
const answerSchema = z.object({
  questionId: id,
  optionId: idOrEmpty.optional(),
  optionIds: z.array(id).max(50).optional(),
  text: z.string().max(20000).optional(),
  blankAnswers: z.record(z.string().max(64), z.string().max(2000)).optional(),
  slotAnswers: z.record(z.string().max(64), idOrEmpty).optional(),
});

const bodySchema = z.object({
  quizId: id,
  answers: z.array(answerSchema).max(200),
});

const supabase = createClient(
  Deno.env.get("SUPABASE_URL")!,
  Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!,
  { auth: { persistSession: false, autoRefreshToken: false } },
);

Deno.serve(async (request) => {
  const preflight = handlePreflight(request);
  if (preflight) return preflight;

  const headers = { ...corsHeaders(request), "Content-Type": "application/json" };
  const reply = (status: number, body: unknown) =>
    new Response(JSON.stringify(body), { status, headers });

  if (request.method !== "POST") {
    return reply(405, { code: "METHOD_NOT_ALLOWED", message: "Método não permitido." });
  }

  const token = request.headers.get("Authorization")?.replace(/^Bearer /, "") ?? "";
  const { data: auth } = token ? await supabase.auth.getClaims(token) : { data: null };
  const authUserId = auth?.claims.sub;
  if (!authUserId) {
    return reply(401, { code: "UNAUTHORIZED", message: "Sessão expirada. Faça login novamente." });
  }

  const body = bodySchema.safeParse(await request.json().catch(() => null));
  if (!body.success) {
    return reply(400, { code: "VALIDATION_ERROR", message: "Respostas inválidas." });
  }

  const { data, error, status } = await supabase.rpc("submit_quiz_attempt", {
    p_auth_user_id: authUserId,
    p_quiz_id: Number(body.data.quizId),
    p_answers: body.data.answers,
  });

  if (error) {
    // Errors raised by private.raise_api_error already carry the contract's
    // { code, message } and HTTP status; anything else is unexpected.
    if (status >= 400 && status < 500) {
      return reply(status, { code: error.code, message: error.message });
    }
    console.error(error);
    return reply(500, {
      code: "UNKNOWN_ERROR",
      message: "Ocorreu um erro inesperado. Tente novamente.",
    });
  }

  return reply(200, data);
});
