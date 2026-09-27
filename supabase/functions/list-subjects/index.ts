// GET list-subjects: Subject[] (docs/04-contratos-de-api.md §3.9, GET /subjects).
import { serveEndpoint } from "../_shared/http.ts";
import { loadSubjectSummaries } from "../_shared/subjects.ts";

serveEndpoint("GET", ({ studentId }) => loadSubjectSummaries(studentId));
