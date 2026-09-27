// GET list-quizzes: QuizSummary[] (docs/04-contratos-de-api.md §3.10, GET /quizzes). Integrated
// quizzes come first; quizzes without questions are left out.
import { sql } from "../_shared/db.ts";
import { serveEndpoint } from "../_shared/http.ts";

type QuizRow = {
  id: number;
  title: string;
  subject_scope: "single" | "all";
  subject_name: string | null;
  question_count: number;
  duration_minutes: number;
  attempts_count: number;
  difficulty: "easy" | "medium" | "hard";
};

serveEndpoint("GET", async ({ studentId }) => {
  const quizzes = await sql<QuizRow[]>`
    select
      z.id,
      z.title,
      z.subject_scope,
      s.name as subject_name,
      summary.question_count::int,
      z.duration_minutes,
      (
        select count(*) from quiz_attempts a where a.quiz_id = z.id and a.student_id = ${studentId}
      )::int as attempts_count,
      z.difficulty
    from quizzes z
    join private.v_quiz_summary summary on summary.quiz_id = z.id
    left join subjects s on s.id = z.subject_id
    where summary.question_count > 0
    order by z.subject_scope = 'all' desc, z.title
  `;

  return quizzes.map((quiz) => ({
    id: String(quiz.id),
    title: quiz.title,
    subjectScope: quiz.subject_scope,
    subjectName: quiz.subject_name ?? undefined,
    questionCount: quiz.question_count,
    durationMinutes: quiz.duration_minutes,
    attemptsCount: quiz.attempts_count,
    difficulty: quiz.difficulty,
  }));
});
