// GET get-current-student: the signed-in student (StudentUser, docs/04-contratos-de-api.md §3.1),
// read right after login.
import { sql } from "../_shared/db.ts";
import { serveEndpoint } from "../_shared/http.ts";

serveEndpoint("GET", async ({ studentId }) => {
  const [student] = await sql<{ id: number; course: string }[]>`
    select id, course from students where id = ${studentId}
  `;
  return { id: String(student.id), course: student.course };
});
