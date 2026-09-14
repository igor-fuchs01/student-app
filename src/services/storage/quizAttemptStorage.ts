import { storedQuizAttemptSchema, type StoredQuizAttempt } from "@models/quizzes";

const ATTEMPT_KEY_PREFIX = "student-app:quiz-attempt";

function attemptKey(userId: string, quizId: string): string {
  return `${ATTEMPT_KEY_PREFIX}:${userId}:${quizId}`;
}

export const quizAttemptStorage = {
  save(userId: string, attempt: StoredQuizAttempt): void {
    localStorage.setItem(attemptKey(userId, attempt.quiz.id), JSON.stringify(attempt));
  },

  load(userId: string, quizId: string): StoredQuizAttempt | null {
    const raw = localStorage.getItem(attemptKey(userId, quizId));
    if (!raw) return null;

    try {
      const attempt = storedQuizAttemptSchema.safeParse(JSON.parse(raw));
      return attempt.success ? attempt.data : null;
    } catch {
      return null;
    }
  },
};
