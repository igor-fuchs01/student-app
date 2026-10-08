import { useState } from "react";
import { useNavigate, useSearchParams } from "react-router-dom";
import { useQuery } from "@tanstack/react-query";
import { StatusMessage } from "@components/ui/StatusMessage";
import { PageLayout } from "@components/layout/PageLayout";
import { StartQuizModal } from "@features/quizzes/components/StartQuizModal";
import { groupExercises, lessonStatus } from "@features/exercises/groupExercises";
import { quizzesApi } from "@services/api/quizzesApi";
import { subjectsApi } from "@services/api/subjectsApi";
import type { ExerciseSummary } from "@models/quizzes";
import { LessonNav } from "./LessonNav";
import { LessonPanel } from "./LessonPanel";
import { StyledHiddenTitle, StyledLayout } from "./ExercisesPage.styles";

export function ExercisesPage() {
  const navigate = useNavigate();
  const [searchParams, setSearchParams] = useSearchParams();
  const [startModalExercise, setStartModalExercise] = useState<ExerciseSummary | null>(null);

  const exercisesQuery = useQuery({
    queryKey: ["exercises", "all"],
    queryFn: ({ signal }) => quizzesApi.getExercises({}, signal),
  });

  // The subject and the lesson live in the URL, so back, reload and shared links keep them.
  // "assunto" is the older name of "aula", still used by "Praticar questões".
  const requestedLessonId = searchParams.get("aula") ?? searchParams.get("assunto") ?? undefined;
  const subjects = exercisesQuery.data ? groupExercises(exercisesQuery.data) : [];
  const subjectOfLesson = subjects.find((item) =>
    item.lessons.some((lesson) => lesson.topicId === requestedLessonId),
  );
  const subject =
    subjects.find((item) => item.subjectId === searchParams.get("disciplina")) ??
    subjectOfLesson ??
    subjects[0];
  const chosenLesson = subject?.lessons.find((lesson) => lesson.topicId === requestedLessonId);
  // Without a choice, the first lesson with a list still to do is shown next to the list.
  const lesson =
    chosenLesson ??
    subject?.lessons.find((item) => lessonStatus(item) !== "done") ??
    subject?.lessons[0];

  // Same key as the subject detail screen, so both share the cached summaries and key points.
  const subjectQuery = useQuery({
    queryKey: ["subject", subject?.subjectId],
    queryFn: ({ signal }) => subjectsApi.getSubject(subject?.subjectId ?? "", signal),
    enabled: Boolean(subject),
  });
  const lessonContent = subjectQuery.data?.topics.find((topic) => topic.id === lesson?.topicId);

  function selectSubject(subjectId: string) {
    setSearchParams({ disciplina: subjectId });
  }

  function selectLesson(topicId: string) {
    if (!subject) return;
    setSearchParams({ disciplina: subject.subjectId, aula: topicId });
    window.scrollTo({ top: 0 });
  }

  function confirmStart() {
    if (!startModalExercise) return;
    navigate(`/exercicios/${startModalExercise.id}`, { state: { timeLimitEnabled: false } });
  }

  return (
    <PageLayout active="exercicios">
      <StyledHiddenTitle>Exercícios</StyledHiddenTitle>

      {exercisesQuery.isLoading && <StatusMessage message="Carregando exercícios…" />}

      {exercisesQuery.isError && (
        <StatusMessage
          message="Não foi possível carregar os exercícios agora."
          error={exercisesQuery.error}
          action={{ label: "Tentar novamente", onClick: () => exercisesQuery.refetch() }}
        />
      )}

      {exercisesQuery.data && !subject && (
        <StatusMessage message="Ainda não há exercícios publicados." />
      )}

      {requestedLessonId && subject && !subjectOfLesson && (
        <StatusMessage
          message="Ainda não há exercícios para este assunto."
          action={{ label: "Ver todos os exercícios", onClick: () => setSearchParams({}) }}
        />
      )}

      {subject && lesson && (!requestedLessonId || subjectOfLesson) && (
        <StyledLayout $showLesson={Boolean(chosenLesson)}>
          <LessonNav
            key={subject.subjectId}
            subjects={subjects}
            subject={subject}
            selectedLessonId={lesson.topicId}
            onSubjectChange={selectSubject}
            onLessonSelect={selectLesson}
          />
          <LessonPanel
            key={lesson.topicId}
            lesson={lesson}
            content={lessonContent}
            contentStatus={subjectQuery.status}
            onStart={setStartModalExercise}
            onBack={() => selectSubject(subject.subjectId)}
          />
        </StyledLayout>
      )}

      {startModalExercise && (
        <StartQuizModal
          quizTitle={startModalExercise.title}
          questionCount={startModalExercise.questionCount}
          onCancel={() => setStartModalExercise(null)}
          onConfirm={confirmStart}
        />
      )}
    </PageLayout>
  );
}
