// GET get-dashboard: DashboardData (docs/04-contratos-de-api.md §3.4, GET /dashboard). todayPlan
// is always empty: study plans are not persisted yet (docs/05-melhorias-futuras.md, item 4).
import { sql } from "../_shared/db.ts";
import { serveEndpoint } from "../_shared/http.ts";

const WEEKDAYS = [
  "Segunda-feira",
  "Terça-feira",
  "Quarta-feira",
  "Quinta-feira",
  "Sexta-feira",
  "Sábado",
  "Domingo",
];

type ExamRow = {
  subject_id: number;
  subject_name: string;
  note: string;
  iso_weekday: number;
  day_month: string;
  overall_preparation: number;
};

type PriorityRow = { id: number; name: string; percent: number };

function plural(count: number, singular: string, pluralForm: string): string {
  return `${count} ${count === 1 ? singular : pluralForm}`;
}

// A topic below 50% is a high priority, below 80% a medium one.
function priorityLevel(percent: number): "high" | "medium" | "low" {
  if (percent < 50) return "high";
  if (percent < 80) return "medium";
  return "low";
}

async function loadNextExam(studentId: number) {
  const [exam] = await sql<ExamRow[]>`
    select
      s.id as subject_id,
      s.name as subject_name,
      e.note,
      extract(isodow from e.exam_date)::int as iso_weekday,
      to_char(e.exam_date, 'DD/MM') as day_month,
      coalesce(performance.preparation_percent, 0)::float8 as overall_preparation
    from scheduled_exams e
    join subjects s on s.id = e.subject_id
    left join private.v_student_subject_performance performance
      on performance.subject_id = s.id and performance.student_id = ${studentId}
    where e.exam_date >= current_date
    order by e.exam_date, e.id
    limit 1
  `;

  if (!exam) {
    return {
      subjectName: "Nenhuma prova agendada",
      dateLabel: "Sem data",
      note: "As prioridades aparecem quando houver uma prova",
      overallPreparation: 0,
      priorities: [],
    };
  }

  const priorities = await sql<PriorityRow[]>`
    select topic.id, topic.name, performance.percent::float8
    from private.v_student_topic_performance performance
    join topics topic on topic.id = performance.topic_id
    where performance.student_id = ${studentId}
      and topic.subject_id = ${exam.subject_id}
      and performance.percent is not null
    order by performance.percent, topic.name
  `;

  return {
    subjectName: exam.subject_name,
    dateLabel: `${WEEKDAYS[exam.iso_weekday - 1]}, ${exam.day_month}`,
    note: exam.note,
    overallPreparation: exam.overall_preparation,
    priorities: priorities.map((topic) => ({
      id: String(topic.id),
      topicName: topic.name,
      level: priorityLevel(topic.percent),
    })),
  };
}

serveEndpoint("GET", async ({ studentId }) => {
  const [nextExam, [streak], subjects, [quizzes]] = await Promise.all([
    loadNextExam(studentId),
    sql<{ streak_days: number }[]>`
      select coalesce(
        (select streak_days from private.v_student_streak where student_id = ${studentId}),
        0
      )::int as streak_days
    `,
    sql<{ name: string }[]>`select name from subjects order by name`,
    sql<{ count: number }[]>`
      select count(*)::int as count from private.v_quiz_summary where question_count > 0
    `,
  ]);

  return {
    streakDays: streak.streak_days,
    nextExam,
    todayPlan: [],
    summaryCards: [
      {
        id: "subjects",
        title: "Disciplinas",
        value: plural(subjects.length, "matéria", "matérias"),
        description:
          subjects.length > 0
            ? `${subjects.map((subject) => subject.name).join(", ")}.`
            : "Nenhuma disciplina cadastrada.",
      },
      {
        id: "quizzes",
        title: "Simulados",
        value: plural(quizzes.count, "disponível", "disponíveis"),
        description: "Por disciplina ou integrados, quantas vezes você quiser.",
      },
      {
        id: "ranking",
        title: "Ranking",
        value: plural(streak.streak_days, "dia de sequência", "dias de sequência"),
        description: "Baseado em consistência de estudo, não em nota.",
      },
    ],
  };
});
