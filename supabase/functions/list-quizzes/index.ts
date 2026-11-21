// GET list-quizzes: QuizSummary[] (docs/04-contratos-de-api.md §3.10, GET /quizzes). Ordered by
// title; exercise lists (GET /exercises) and quizzes without questions are left out.
import { sql } from "../_shared/db.ts";
import { serveEndpoint } from "../_shared/http.ts";

type QuizRow = {
  id: number;
  title: string;
  subject_name: string;
  question_count: number;
  duration_minutes: number;
  attempts_count: number;
  difficulty: "easy" | "medium" | "hard";
  semester: number;
  sprints: number[];
};

// One row per subassunto of each assunto a simulado's questions belong to; an assunto without
// subassuntos comes once, with subtopic_name null.
type TopicRow = {
  quiz_id: number;
  topic_number: number;
  topic_name: string;
  subtopic_name: string | null;
};

type QuizTopic = { number: number; name: string; subtopics: string[] };

function groupTopics(rows: TopicRow[]): Map<number, QuizTopic[]> {
  const byQuiz = new Map<number, QuizTopic[]>();
  for (const row of rows) {
    const topics = byQuiz.get(row.quiz_id) ?? [];
    let topic = topics.at(-1);
    if (topic?.number !== row.topic_number) {
      topic = { number: row.topic_number, name: row.topic_name, subtopics: [] };
      topics.push(topic);
    }
    if (row.subtopic_name !== null) topic.subtopics.push(row.subtopic_name);
    byQuiz.set(row.quiz_id, topics);
  }
  return byQuiz;
}

serveEndpoint("GET", async ({ studentId }) => {
  const [quizzes, topicRows] = await Promise.all([
    sql<QuizRow[]>`
      select
        z.id,
        z.title,
        s.name as subject_name,
        summary.question_count::int,
        z.duration_minutes,
        (
          select count(*) from quiz_attempts a where a.quiz_id = z.id and a.student_id = ${studentId}
        )::int as attempts_count,
        z.difficulty,
        s.semester::int,
        array(
          select qs.sprint::int from quiz_sprints qs where qs.quiz_id = z.id order by qs.sprint
        ) as sprints
      from quizzes z
      join private.v_quiz_summary summary on summary.quiz_id = z.id
      join subjects s on s.id = z.subject_id
      where z.kind = 'exam' and summary.question_count > 0
      order by z.title
    `,
    sql<TopicRow[]>`
      select
        covered.quiz_id,
        t.number as topic_number,
        t.name as topic_name,
        st.name as subtopic_name
      from (
        select distinct qq.quiz_id, q.topic_id
        from quiz_questions qq
        join quizzes z on z.id = qq.quiz_id and z.kind = 'exam'
        join questions q on q.id = qq.question_id
      ) covered
      join topics t on t.id = covered.topic_id
      left join subtopics st on st.topic_id = t.id
      order by covered.quiz_id, t.number, st.order_index
    `,
  ]);

  const topicsByQuiz = groupTopics(topicRows);

  return quizzes.map((quiz) => ({
    id: String(quiz.id),
    title: quiz.title,
    subjectName: quiz.subject_name,
    questionCount: quiz.question_count,
    durationMinutes: quiz.duration_minutes,
    attemptsCount: quiz.attempts_count,
    difficulty: quiz.difficulty,
    semester: quiz.semester,
    sprints: quiz.sprints,
    topics: topicsByQuiz.get(quiz.id) ?? [],
  }));
});
