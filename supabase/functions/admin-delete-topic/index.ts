// POST admin-delete-topic: deletes an assunto with its subassuntos and materials
// (docs/04-contratos-de-api.md, POST /admin/topics/delete). Refused with 409 while a question or
// an exercise list belongs to it.
import { serveAdminDelete } from "../_shared/admin.ts";

serveAdminDelete("topics", "Assunto não encontrado.");
