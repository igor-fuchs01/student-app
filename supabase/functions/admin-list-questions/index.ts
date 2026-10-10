// GET admin-list-questions?subjectId=&topicId=: AdminQuestionSummary[]
// (docs/04-contratos-de-api.md, GET /admin/questions), newest first. Both filters are optional.
import { serveAdminEndpoint, ApiError } from "../_shared/http.ts";
import { loadQuestionSummaries } from "../_shared/adminQuestions.ts";

function readFilter(url: URL, name: string): number | undefined {
  const value = url.searchParams.get(name);
  if (value === null) return undefined;
  if (!/^\d{1,9}$/.test(value)) throw new ApiError(400, "VALIDATION_ERROR", "Filtro inválido.");
  return Number(value);
}

serveAdminEndpoint("GET", ({ url }) =>
  loadQuestionSummaries({
    subjectId: readFilter(url, "subjectId"),
    topicId: readFilter(url, "topicId"),
  }),
);
