// What the admin quiz endpoints share: the quiz summary and the rules that are the same whether
// the quiz comes from the editor (admin-save-quiz) or from an imported JSON (admin-import-quiz).
import { z } from "npm:zod@4";
import { text, type Tx } from "./admin.ts";
import { sql } from "./db.ts";
import { ApiError } from "./http.ts";

export const quizFields = {
  title: text(200),
  kind: z.enum(["exam", "exercise"]),
  durationMinutes: z.number().int().min(1).max(600).optional(),
  difficulty: z.enum(["easy", "medium", "hard"]),
};

// An exercise list belongs to one assunto and has no time limit; a simulado is the opposite. The
// CHECK constraints of quizzes say the same, but would answer with a 500.
export function kindProblems(
  kind: "exam" | "exercise",
  durationMinutes: number | undefined,
  hasTopic: boolean,
): string[] {
  if (kind === "exercise") {
    return [
      ...(hasTopic ? [] : ["Uma lista de exercícios precisa de um assunto."]),
      ...(durationMinutes === undefined ? [] : ["Uma lista de exercícios não tem duração."]),
    ];
  }
  return [
    ...(hasTopic ? ["Um simulado não tem assunto: ele é da disciplina inteira."] : []),
    ...(durationMinutes === undefined ? ["Informe a duração do simulado, em minutos."] : []),
  ];
}

// The title identifies the quiz to the admin and to the student, so it is unique.
export async function assertTitleAvailable(tx: Tx, title: string, quizId?: number): Promise<void> {
  const [sameTitle] = await tx<{ id: number }[]>`
    select id from quizzes where title = ${title} and id is distinct from ${quizId ?? null}
  `;
  if (sameTitle) {
    throw new ApiError(409, "CONFLICT", "Já existe um simulado ou lista com esse título.");
  }
}

// Replaces the questions of a quiz by the ids given, in that order.
export async function writeQuizQuestions(
  tx: Tx,
  quizId: number,
  questionIds: number[],
): Promise<void> {
  await tx`delete from quiz_questions where quiz_id = ${quizId}`;
  for (const [index, questionId] of questionIds.entries()) {
    await tx`
      insert into quiz_questions (quiz_id, question_id, order_index)
      values (${quizId}, ${questionId}, ${index + 1})
    `;
  }
}

type QuizRow = {
  id: number;
  title: string;
  kind: "exam" | "exercise";
  subject_id: number;
  subject_name: string;
  topic_id: number | null;
  topic_name: string | null;
  duration_minutes: number | null;
  difficulty: "easy" | "medium" | "hard";
  question_count: number;
  attempts_count: number;
};

// AdminQuizSummary[]: every simulado and exercise list, or only the one of quizId. Unlike the
// student's lists, it includes quizzes that have no question yet and counts everyone's attempts.
export async function loadQuizSummaries(quizId?: number) {
  const rows = await sql<QuizRow[]>`
    select
      z.id, z.title, z.kind, z.subject_id, s.name as subject_name, z.topic_id,
      t.name as topic_name, z.duration_minutes, z.difficulty,
      (select count(*) from quiz_questions qq where qq.quiz_id = z.id)::int as question_count,
      (select count(*) from quiz_attempts a where a.quiz_id = z.id)::int as attempts_count
    from quizzes z
    join subjects s on s.id = z.subject_id
    left join topics t on t.id = z.topic_id
    where ${quizId ?? null}::int is null or z.id = ${quizId ?? null}::int
    order by z.title
  `;

  return rows.map((row) => ({
    id: String(row.id),
    title: row.title,
    kind: row.kind,
    subjectId: String(row.subject_id),
    subjectName: row.subject_name,
    topicId: row.topic_id === null ? undefined : String(row.topic_id),
    topicName: row.topic_name ?? undefined,
    durationMinutes: row.duration_minutes ?? undefined,
    difficulty: row.difficulty,
    questionCount: row.question_count,
    attemptsCount: row.attempts_count,
  }));
}
