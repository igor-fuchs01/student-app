import { sql } from "./db.ts";

type SubjectSummaryRow = {
  id: number;
  name: string;
  short_label: string;
  materials_count: number;
  questions_count: number;
  preparation_percent: number;
};

// Subject (docs/04-contratos-de-api.md §3.9) of every subject, or of one. list-subjects and
// get-subject both read it, so the two endpoints can never disagree about a subject.
export async function loadSubjectSummaries(studentId: number, subjectId?: number) {
  const rows = await sql<SubjectSummaryRow[]>`
    select
      s.id,
      s.name,
      s.short_label,
      summary.materials_count::int,
      summary.questions_count::int,
      coalesce(performance.preparation_percent, 0)::float8 as preparation_percent
    from subjects s
    join private.v_subject_summary summary on summary.subject_id = s.id
    left join private.v_student_subject_performance performance
      on performance.subject_id = s.id and performance.student_id = ${studentId}
    ${subjectId === undefined ? sql`` : sql`where s.id = ${subjectId}`}
    order by s.name
  `;

  return rows.map((row) => ({
    id: String(row.id),
    name: row.name,
    shortLabel: row.short_label,
    materialsCount: row.materials_count,
    questionsCount: row.questions_count,
    preparationPercent: row.preparation_percent,
  }));
}
