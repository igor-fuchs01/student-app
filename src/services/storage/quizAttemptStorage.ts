import { storedQuizAttemptSchema, type StoredQuizAttempt } from "@models/quizzes";

const ATTEMPT_KEY_PREFIX = "student-app:quiz-attempt:";

export const quizAttemptStorage = {
  save(attempt: StoredQuizAttempt): void {
    localStorage.setItem(`${ATTEMPT_KEY_PREFIX}${attempt.quiz.id}`, JSON.stringify(attempt));
  },

  load(quizId: string): StoredQuizAttempt | null {
    const raw = localStorage.getItem(`${ATTEMPT_KEY_PREFIX}${quizId}`);
    if (!raw) return null;

    try {
      const attempt = storedQuizAttemptSchema.safeParse(JSON.parse(raw));
      return attempt.success ? attempt.data : null;
    } catch {
      return null;
    }
  },
};
