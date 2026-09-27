// GET get-quiz?id=: QuizDetail (docs/04-contratos-de-api.md §3.11, GET /quizzes/:id). It still
// carries the answer keys, because the current QuizDetail contract does
// (docs/05-melhorias-futuras.md, item 2).
import { sql } from "../_shared/db.ts";
import { ApiError, serveEndpoint } from "../_shared/http.ts";
import { loadQuizQuestions, toQuestionDto } from "../_shared/questions.ts";

type QuizRow = { id: number; title: string; duration_minutes: number };

serveEndpoint("GET", async ({ url }) => {
  // A non-numeric id answers 404, like an unknown quiz; so does a quiz without questions.
  const id = url.searchParams.get("id") ?? "";
  const [quiz] = /^\d{1,9}$/.test(id)
    ? await sql<QuizRow[]>`select id, title, duration_minutes from quizzes where id = ${Number(id)}`
    : [];
  const questions = quiz ? await loadQuizQuestions(quiz.id) : [];
  if (!quiz || questions.length === 0) {
    throw new ApiError(404, "NOT_FOUND", "Simulado não encontrado.");
  }

  return {
    id: String(quiz.id),
    title: quiz.title,
    durationMinutes: quiz.duration_minutes,
    questions: questions.map(toQuestionDto),
  };
});
