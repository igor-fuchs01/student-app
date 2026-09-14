import type { StudentUser } from "@models/auth";
import type { RankingData } from "@models/ranking";

const CURRENT_USER_STREAK_DAYS = 7;

const OTHER_STUDENTS = [
  { studentId: "u_ana", studentName: "Ana Ribeiro", streakDays: 21 },
  { studentId: "u_joao", studentName: "João Pedro", streakDays: 18 },
  { studentId: "u_lucas", studentName: "Lucas Almeida", streakDays: 15 },
  { studentId: "u_pedro", studentName: "Pedro Souza", streakDays: 6 },
];

export function buildMockRanking(currentUser: StudentUser): RankingData {
  const students = [
    ...OTHER_STUDENTS,
    {
      studentId: currentUser.id,
      studentName: currentUser.name,
      streakDays: CURRENT_USER_STREAK_DAYS,
    },
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
