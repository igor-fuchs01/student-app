// POST admin-delete-question: deletes a question with its options, blanks, terms and slots
// (docs/04-contratos-de-api.md, POST /admin/questions/delete). Refused with 409 while a quiz
// holds it or a student has answered it.
import { serveAdminDelete } from "../_shared/admin.ts";

serveAdminDelete("questions", "Questão não encontrada.");
