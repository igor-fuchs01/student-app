// GET get-dashboard?period=&subjectId=: DashboardData (docs/04-contratos-de-api.md §3.4,
// GET /dashboard). The student's preparation and progress in the last `period` days, compared with
// the `period` days before, optionally limited to one subject.
//
// Like the views, a percentage is graded hits over graded answers (pending_review answers are not
// graded yet), from private.percent, and null when nothing was graded.
import { sql } from "../_shared/db.ts";
import { ApiError, serveEndpoint } from "../_shared/http.ts";

const DEFAULT_PERIOD = 90;
const FOCUS_LIMIT = 5;
const FEW_PRACTICE_BELOW = 10;
const RECENT_DAYS = 14;

type ProfileRow = {
  streak_days: number;
  weekly_goal_completed: number;
  weekly_goal_target: number;
};

type TotalsRow = {
  answered: number;
  previous_answered: number;
  percent: number | null;
  previous_percent: number | null;
};

type WeekRow = {
  week_start: string;
  week_end: string;
  answered_count: number;
  graded_count: number;
  correct_count: number;
  percent: number | null;
};

type BreakdownRow = {
  id: number;
  name: string;
  topic_number: number | null;
  graded_count: number;
  correct_count: number;
  percent: number;
};

type FocusRow = {
  id: number;
  name: string;
  number: number;
  subject_id: number;
  short_label: string;
  graded_count: number;
  percent: number | null;
  recent_wrong_count: number;
};

type FocusLevel = "high" | "medium" | "few_practice";

const LEVEL_ORDER: Record<FocusLevel, number> = { high: 0, medium: 1, few_practice: 2 };

// A topic below 50% is a high priority, below 80% a medium one; at 80% or more it is not listed.
function focusLevel(topic: FocusRow): FocusLevel | null {
  if (topic.graded_count < FEW_PRACTICE_BELOW || topic.percent === null) return "few_practice";
  if (topic.percent < 50) return "high";
  if (topic.percent < 80) return "medium";
  return null;
}

// Answers of the student, optionally of one subject. A function, so every query gets its own
// fragment.
function studentAnswers(studentId: number, subjectId: number | null) {
  return sql`
    from quiz_attempt_answers qaa
    join quiz_attempts qa on qa.id = qaa.attempt_id
    join questions q on q.id = qaa.question_id
    join topics t on t.id = q.topic_id
    join subjects s on s.id = t.subject_id
    where qa.student_id = ${studentId}
    ${subjectId === null ? sql`` : sql`and t.subject_id = ${subjectId}`}
  `;
}

async function parseSubjectId(url: URL): Promise<number | null> {
  const value = url.searchParams.get("subjectId");
  if (value === null) return null;

  // A non-numeric id answers 404, like an unknown subject.
  const [subject] = /^\d{1,9}$/.test(value)
    ? await sql<{ id: number }[]>`select id from subjects where id = ${Number(value)}`
    : [];
  if (!subject) throw new ApiError(404, "NOT_FOUND", "Disciplina não encontrada.");
  return subject.id;
}

serveEndpoint("GET", async ({ url, studentId }) => {
  const periodParam = url.searchParams.get("period") ?? String(DEFAULT_PERIOD);
  if (!/^(30|90|180)$/.test(periodParam)) {
    throw new ApiError(400, "VALIDATION_ERROR", "Período inválido.");
  }
  const period = Number(periodParam);
  const subjectId = await parseSubjectId(url);
  const periodStart = sql`current_date - ${period - 1}::int`;
  const graded = sql`qaa.review_status <> 'pending_review'`;
  const correct = sql`qaa.review_status = 'correct'`;

  const [[profile], [totals], weeks, breakdown, topics] = await Promise.all([
    sql<ProfileRow[]>`
      select streak_days::int, weekly_goal_completed::int, weekly_goal_target
      from private.v_student_ranking_profile
      where student_id = ${studentId}
    `,
    sql<TotalsRow[]>`
      select
        answered::int,
        previous_answered::int,
        private.percent(correct, graded)::float8 as percent,
        private.percent(previous_correct, previous_graded)::float8 as previous_percent
      from (
        select
          count(*) filter (where in_period) as answered,
          count(*) filter (where in_period and ${graded}) as graded,
          count(*) filter (where in_period and ${correct}) as correct,
          count(*) filter (where not in_period) as previous_answered,
          count(*) filter (where not in_period and ${graded}) as previous_graded,
          count(*) filter (where not in_period and ${correct}) as previous_correct
        from (
          select qaa.review_status, qa.submitted_at::date >= ${periodStart} as in_period
          ${studentAnswers(studentId, subjectId)}
            and qa.submitted_at::date >= current_date - ${2 * period - 1}::int
        ) qaa
      ) counts
    `,
    sql<WeekRow[]>`
      with weeks as (
        select
          n,
          greatest(current_date - (n * 7 + 6), ${periodStart}) as week_start,
          current_date - n * 7 as week_end
        from generate_series(0, ${Math.ceil(period / 7) - 1}::int) as n
      )
      select
        to_char(w.week_start, 'YYYY-MM-DD') as week_start,
        to_char(w.week_end, 'YYYY-MM-DD') as week_end,
        count(qaa.review_status)::int as answered_count,
        count(*) filter (where ${graded})::int as graded_count,
        count(*) filter (where ${correct})::int as correct_count,
        private.percent(
          count(*) filter (where ${correct}),
          count(*) filter (where ${graded})
        )::float8 as percent
      from weeks w
      left join (
        select qaa.review_status, qa.submitted_at::date as day
        ${studentAnswers(studentId, subjectId)}
      ) qaa on qaa.day between w.week_start and w.week_end
      group by w.n, w.week_start, w.week_end
      order by w.n desc
    `,
    sql<BreakdownRow[]>`
      select
        ${subjectId === null ? sql`s.id, s.name, null::int as topic_number` : sql`t.id, t.name, t.number as topic_number`},
        count(*) filter (where ${graded})::int as graded_count,
        count(*) filter (where ${correct})::int as correct_count,
        private.percent(
          count(*) filter (where ${correct}),
          count(*) filter (where ${graded})
        )::float8 as percent
      ${studentAnswers(studentId, subjectId)}
        and qa.submitted_at::date >= ${periodStart}
      group by ${subjectId === null ? sql`s.id, s.name` : sql`t.id, t.name, t.number`}
      having count(*) filter (where ${graded}) > 0
      order by percent desc, name
    `,
    sql<FocusRow[]>`
      select
        t.id,
        t.name,
        t.number,
        s.id as subject_id,
        s.short_label,
        count(*) filter (where ${graded})::int as graded_count,
        private.percent(
          count(*) filter (where ${correct}),
          count(*) filter (where ${graded})
        )::float8 as percent,
        count(*) filter (
          where qaa.review_status = 'incorrect'
            and qaa.day >= current_date - ${RECENT_DAYS - 1}::int
        )::int as recent_wrong_count
      from topics t
      join subjects s on s.id = t.subject_id
      left join (
        select q.topic_id, qaa.review_status, qa.submitted_at::date as day
        from quiz_attempt_answers qaa
        join quiz_attempts qa on qa.id = qaa.attempt_id
        join questions q on q.id = qaa.question_id
        where qa.student_id = ${studentId}
          and qa.submitted_at::date >= ${periodStart}
      ) qaa on qaa.topic_id = t.id
      ${subjectId === null ? sql`` : sql`where t.subject_id = ${subjectId}`}
      group by t.id, s.id
    `,
  ]);

  // Ordered by docs/02-regras-de-negocio.md §9: low performance first, then recent mistakes,
  // then the least practiced.
  const focus = topics
    .map((topic) => ({ topic, level: focusLevel(topic) }))
    .filter((entry): entry is { topic: FocusRow; level: FocusLevel } => entry.level !== null)
    .sort(
      (a, b) =>
        LEVEL_ORDER[a.level] - LEVEL_ORDER[b.level] ||
        b.topic.recent_wrong_count - a.topic.recent_wrong_count ||
        (a.topic.percent ?? 0) - (b.topic.percent ?? 0) ||
        a.topic.name.localeCompare(b.topic.name),
    );

  return {
    streakDays: profile.streak_days,
    preparation: { percent: totals.percent, previousPercent: totals.previous_percent },
    questionsAnswered: { count: totals.answered, previousCount: totals.previous_answered },
    weeklyGoal: { completed: profile.weekly_goal_completed, target: profile.weekly_goal_target },
    weeklyAccuracy: weeks.map((week) => ({
      weekStart: week.week_start,
      weekEnd: week.week_end,
      answeredCount: week.answered_count,
      gradedCount: week.graded_count,
      correctCount: week.correct_count,
      percent: week.percent,
    })),
    preparationBreakdown: {
      scope: subjectId === null ? "subject" : "topic",
      items: breakdown.map((item) => ({
        id: String(item.id),
        name: item.name,
        ...(item.topic_number === null ? {} : { topicNumber: item.topic_number }),
        gradedCount: item.graded_count,
        correctCount: item.correct_count,
        percent: item.percent,
      })),
    },
    studyFocus: {
      items: focus.slice(0, FOCUS_LIMIT).map(({ topic, level }) => ({
        topicId: String(topic.id),
        topicName: topic.name,
        topicNumber: topic.number,
        subjectId: String(topic.subject_id),
        subjectShortLabel: topic.short_label,
        percent: topic.percent,
        gradedCount: topic.graded_count,
        recentWrongCount: topic.recent_wrong_count,
        level,
      })),
      totalCount: focus.length,
    },
  };
});
