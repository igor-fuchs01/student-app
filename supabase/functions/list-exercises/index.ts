// GET list-exercises?topicId=: ExerciseSummary[] (docs/04-contratos-de-api.md §3.20,
// GET /exercises). With topicId only that topic's lists are read, through idx_quizzes_topic_id.
// Ordered by subject, lesson number and title; lists without questions are left out.
import { sql } from "../_shared/db.ts";
import { ApiError, serveEndpoint } from "../_shared/http.ts";

type ExerciseRow = {
  id: number;
  title: string;
  subject_id: number;
  subject_name: string;
  topic_id: number;
  topic_number: number;
  topic_name: string;
  question_count: number;
  attempts_count: number;
  difficulty: "easy" | "medium" | "hard";
};

async function parseTopicId(url: URL): Promise<number | null> {
  const value = url.searchParams.get("topicId");
  if (value === null) return null;

  // A non-numeric id answers 404, like an unknown topic.
  const [topic] = /^\d{1,9}$/.test(value)
    ? await sql<{ id: number }[]>`select id from topics where id = ${Number(value)}`
    : [];
  if (!topic) throw new ApiError(404, "NOT_FOUND", "Assunto não encontrado.");
  return topic.id;
}

serveEndpoint("GET", async ({ studentId, url }) => {
  const topicId = await parseTopicId(url);

  // The student's attempts are counted once per list in a join, instead of a subquery per row.
  const exercises = await sql<ExerciseRow[]>`
    select
      z.id,
      z.title,
      s.id as subject_id,
      s.name as subject_name,
      t.id as topic_id,
      t.number as topic_number,
      t.name as topic_name,
      summary.question_count::int,
      coalesce(attempts.attempts_count, 0)::int as attempts_count,
      z.difficulty
    from quizzes z
    join topics t on t.id = z.topic_id
    join subjects s on s.id = t.subject_id
    join private.v_quiz_summary summary on summary.quiz_id = z.id
    left join (
      select a.quiz_id, count(*) as attempts_count
      from quiz_attempts a
      where a.student_id = ${studentId}
      group by a.quiz_id
    ) attempts on attempts.quiz_id = z.id
    where z.kind = 'exercise'
      and summary.question_count > 0
      ${topicId === null ? sql`` : sql`and z.topic_id = ${topicId}`}
    order by s.name, t.number, z.title
  `;

  return exercises.map((exercise) => ({
    id: String(exercise.id),
    title: exercise.title,
    subjectId: String(exercise.subject_id),
    subjectName: exercise.subject_name,
    topicId: String(exercise.topic_id),
    topicNumber: exercise.topic_number,
    topicName: exercise.topic_name,
    questionCount: exercise.question_count,
    attemptsCount: exercise.attempts_count,
    difficulty: exercise.difficulty,
  }));
});
