// POST admin-delete-subtopic: deletes a subassunto with its key points and materials
// (docs/04-contratos-de-api.md, POST /admin/subtopics/delete).
import { serveAdminDelete } from "../_shared/admin.ts";

serveAdminDelete("subtopics", "Subassunto não encontrado.");
