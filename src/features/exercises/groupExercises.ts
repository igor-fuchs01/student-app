import type { ExerciseSummary } from "@models/quizzes";

export type LessonGroup = {
  topicId: string;
  topicNumber: number;
  topicName: string;
  exercises: ExerciseSummary[];
};

export type SubjectGroup = { subjectId: string; subjectName: string; lessons: LessonGroup[] };

export type LessonStatus = "done" | "started" | "pending";

// Groups the lists by subject and, inside it, by lesson (aula), whatever their difficulty. The API
// already orders them by subject, lesson and title, so grouping keeps that order.
export function groupExercises(exercises: ExerciseSummary[]): SubjectGroup[] {
  const subjects: SubjectGroup[] = [];

  for (const exercise of exercises) {
    let subject = subjects.find((item) => item.subjectId === exercise.subjectId);
    if (!subject) {
      subject = { subjectId: exercise.subjectId, subjectName: exercise.subjectName, lessons: [] };
      subjects.push(subject);
    }

    let lesson = subject.lessons.find((item) => item.topicId === exercise.topicId);
    if (!lesson) {
      lesson = {
        topicId: exercise.topicId,
        topicNumber: exercise.topicNumber,
        topicName: exercise.topicName,
        exercises: [],
      };
      subject.lessons.push(lesson);
    }

    lesson.exercises.push(exercise);
  }

  return subjects;
}

// A list counts as done once the student has sent it at least once.
export function isExerciseDone(exercise: ExerciseSummary): boolean {
  return exercise.attemptsCount > 0;
}

export function countDone(lesson: LessonGroup): number {
  return lesson.exercises.filter(isExerciseDone).length;
}

export function lessonStatus(lesson: LessonGroup): LessonStatus {
  const done = countDone(lesson);
  if (done === lesson.exercises.length) return "done";
  return done > 0 ? "started" : "pending";
}
