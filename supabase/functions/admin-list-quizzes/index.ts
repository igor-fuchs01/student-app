// GET admin-list-quizzes: AdminQuizSummary[] (docs/04-contratos-de-api.md, GET /admin/quizzes),
// simulados and exercise lists together, by title.
import { loadQuizSummaries } from "../_shared/adminQuizzes.ts";
import { serveAdminEndpoint } from "../_shared/http.ts";

serveAdminEndpoint("GET", () => loadQuizSummaries());
