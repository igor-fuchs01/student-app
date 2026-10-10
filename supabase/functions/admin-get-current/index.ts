// GET admin-get-current: the signed-in admin (AdminUser, docs/04-contratos-de-api.md,
// GET /admin/me). The admin login and the /admin route guard call it to learn whether the session
// belongs to an admin; serveAdminEndpoint has already answered 403 when it does not.
import { sql } from "../_shared/db.ts";
import { serveAdminEndpoint } from "../_shared/http.ts";

serveAdminEndpoint("GET", async ({ adminAuthUserId }) => {
  const [admin] = await sql<{ id: number }[]>`
    select id from admins where auth_user_id = ${adminAuthUserId}
  `;
  return { id: String(admin.id) };
});
