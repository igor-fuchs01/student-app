// POST admin-delete-quiz: deletes a simulado or an exercise list; its questions stay in the bank
// (docs/04-contratos-de-api.md, POST /admin/quizzes/delete). Refused with 409 once a student has
// submitted an attempt.
import { serveAdminDelete } from "../_shared/admin.ts";

serveAdminDelete("quizzes", "Simulado não encontrado.");
