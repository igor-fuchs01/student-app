// POST admin-delete-subject: deletes a subject with its assuntos, subassuntos and materials
// (docs/04-contratos-de-api.md, POST /admin/subjects/delete). Refused with 409 while a question
// or a quiz belongs to it.
import { serveAdminDelete } from "../_shared/admin.ts";

serveAdminDelete("subjects", "Disciplina não encontrada.");
