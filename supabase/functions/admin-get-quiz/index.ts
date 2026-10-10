// GET admin-get-quiz?id=: one simulado or exercise list with its questions in display order
// (AdminQuizDetail, docs/04-contratos-de-api.md, GET /admin/quizzes/:id).
import { readQueryId } from "../_shared/admin.ts";
import { loadQuestionSummaries } from "../_shared/adminQuestions.ts";
import { loadQuizSummaries } from "../_shared/adminQuizzes.ts";
import { ApiError, serveAdminEndpoint } from "../_shared/http.ts";

serveAdminEndpoint("GET", async ({ url }) => {
  const id = readQueryId(url, "Simulado não encontrado.");

  const [[quiz], questions] = await Promise.all([
    loadQuizSummaries(id),
    loadQuestionSummaries({ quizId: id }),
  ]);
  if (!quiz) throw new ApiError(404, "NOT_FOUND", "Simulado não encontrado.");

  return { ...quiz, questions };
});
