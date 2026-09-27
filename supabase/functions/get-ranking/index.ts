// GET get-ranking: RankingData (docs/04-contratos-de-api.md §3.15, GET /ranking). Other students
// expose only an id and a streak, never grades (docs/02-regras-de-negocio.md §11).
import { sql } from "../_shared/db.ts";
import { serveEndpoint } from "../_shared/http.ts";

type ProfileRow = {
  streak_days: number;
  weekly_goal_completed: number;
  weekly_goal_target: number;
  questions_answered: number;
  quizzes_completed: number;
};

type EntryRow = { position: number; student_id: number; streak_days: number };

serveEndpoint("GET", async ({ studentId }) => {
  const [[profile], entries] = await Promise.all([
    sql<ProfileRow[]>`
      select
        streak_days::int,
        weekly_goal_completed::int,
        weekly_goal_target,
        questions_answered::int,
        quizzes_completed::int
      from private.v_student_ranking_profile
      where student_id = ${studentId}
    `,
    sql<EntryRow[]>`
      select position::int, student_id, streak_days::int
      from private.v_student_ranking
      order by position, student_id
    `,
  ]);

  return {
    profile: {
      streakDays: profile.streak_days,
      weeklyGoalCompleted: profile.weekly_goal_completed,
      weeklyGoalTarget: profile.weekly_goal_target,
      questionsAnswered: profile.questions_answered,
      quizzesCompleted: profile.quizzes_completed,
    },
    entries: entries.map((entry) => ({
      position: entry.position,
      studentId: String(entry.student_id),
      streakDays: entry.streak_days,
      isCurrentUser: entry.student_id === studentId,
    })),
  };
});
