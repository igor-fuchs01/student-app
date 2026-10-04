// GET get-activity-calendar?month=: ActivityCalendar (docs/04-contratos-de-api.md §3.21,
// GET /ranking/activity). Only the student's own days: the calendar is never shown to others
// (docs/02-regras-de-negocio.md §11).
import { sql } from "../_shared/db.ts";
import { ApiError, serveEndpoint } from "../_shared/http.ts";

type DayRow = { date: string; exams_count: number; exercises_count: number };

const MONTH = /^\d{4}-(0[1-9]|1[0-2])$/;

serveEndpoint("GET", async ({ studentId, url }) => {
  // Without month, the current one; dates follow the database clock, like current_date when the
  // study day is recorded by submit-quiz-attempt.
  const month = url.searchParams.get("month") ?? new Date().toISOString().slice(0, 7);
  if (!MONTH.test(month)) {
    throw new ApiError(400, "VALIDATION_ERROR", "Mês inválido.");
  }
  const monthStart = `${month}-01`;

  // A day is in the calendar when it is a study day or has a submitted attempt; each day then
  // counts its simulados and exercise lists.
  const days = await sql<DayRow[]>`
    with month_days as (
      select activity_date as day
      from student_activity_days
      where student_id = ${studentId}
        and activity_date >= ${monthStart}::date
        and activity_date < ${monthStart}::date + interval '1 month'
      union
      select submitted_at::date
      from quiz_attempts
      where student_id = ${studentId}
        and submitted_at >= ${monthStart}::date
        and submitted_at < ${monthStart}::date + interval '1 month'
    )
    select
      to_char(d.day, 'YYYY-MM-DD') as date,
      count(z.id) filter (where z.kind = 'exam')::int as exams_count,
      count(z.id) filter (where z.kind = 'exercise')::int as exercises_count
    from month_days d
    left join quiz_attempts qa on qa.student_id = ${studentId} and qa.submitted_at::date = d.day
    left join quizzes z on z.id = qa.quiz_id
    group by d.day
    order by d.day
  `;

  return {
    month,
    days: days.map((day) => ({
      date: day.date,
      examsCount: day.exams_count,
      exercisesCount: day.exercises_count,
    })),
  };
});
