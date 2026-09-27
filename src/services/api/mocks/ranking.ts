import type { StudentUser } from "@models/auth";
import type { RankingData } from "@models/ranking";

const CURRENT_USER_STREAK_DAYS = 7;

const OTHER_STUDENTS = [
  { studentId: "u_demo0002", streakDays: 21 },
  { studentId: "u_demo0003", streakDays: 18 },
  { studentId: "u_demo0004", streakDays: 15 },
  { studentId: "u_demo0005", streakDays: 6 },
];

export function buildMockRanking(currentUser: StudentUser): RankingData {
  const students = [
    ...OTHER_STUDENTS,
    { studentId: currentUser.id, streakDays: CURRENT_USER_STREAK_DAYS },
  ].sort((a, b) => b.streakDays - a.streakDays);

  return {
    profile: {
      streakDays: CURRENT_USER_STREAK_DAYS,
      weeklyGoalCompleted: 32,
      weeklyGoalTarget: 50,
      questionsAnswered: 312,
      quizzesCompleted: 14,
    },
    entries: students.map((student, index) => ({
      ...student,
      position: index + 1,
      isCurrentUser: student.studentId === currentUser.id,
    })),
  };
}
