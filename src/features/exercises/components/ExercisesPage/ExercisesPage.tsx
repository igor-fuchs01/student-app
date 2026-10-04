import { useState } from "react";
import { useNavigate, useSearchParams } from "react-router-dom";
import { useQuery } from "@tanstack/react-query";
import { Badge } from "@components/ui/Badge";
import { Button } from "@components/ui/Button";
import { StatusMessage } from "@components/ui/StatusMessage";
import { PageLayout } from "@components/layout/PageLayout";
import { StartQuizModal } from "@features/quizzes/components/StartQuizModal";
import { DIFFICULTY_LABEL } from "@features/quizzes/difficultyLabel";
import { quizzesApi } from "@services/api/quizzesApi";
import type { ExerciseSummary } from "@models/quizzes";
import { formatCount } from "@utils/formatCount";
import {
  StyledPageTitle,
  StyledPageSubtitle,
  StyledAllLink,
  StyledSubjectSection,
  StyledSubjectTitle,
  StyledGrid,
  StyledExerciseCard,
  StyledExerciseTitle,
  StyledExerciseMeta,
  StyledCardFooter,
} from "./ExercisesPage.styles";

type SubjectGroup = { subjectId: string; subjectName: string; exercises: ExerciseSummary[] };

// The API already orders the lists by subject, so grouping keeps that order.
function groupBySubject(exercises: ExerciseSummary[]): SubjectGroup[] {
  const groups: SubjectGroup[] = [];

  for (const exercise of exercises) {
    const group = groups.find((item) => item.subjectId === exercise.subjectId);
    if (group) {
      group.exercises.push(exercise);
    } else {
      groups.push({
        subjectId: exercise.subjectId,
        subjectName: exercise.subjectName,
        exercises: [exercise],
      });
    }
  }

  return groups;
}

export function ExercisesPage() {
  const navigate = useNavigate();
  const [searchParams] = useSearchParams();
  const topicId = searchParams.get("assunto") ?? undefined;
  const [startModalExercise, setStartModalExercise] = useState<ExerciseSummary | null>(null);

  // The API filters by topic, so a topic's screen only downloads that topic's lists.
  const exercisesQuery = useQuery({
    queryKey: ["exercises", topicId ?? "all"],
    queryFn: ({ signal }) => quizzesApi.getExercises({ topicId }, signal),
  });

  const exercises = exercisesQuery.data;
  const topic = topicId ? exercises?.[0] : undefined;

  function confirmStart() {
    if (!startModalExercise) return;
    navigate(`/exercicios/${startModalExercise.id}`, { state: { timeLimitEnabled: false } });
  }

  return (
    <PageLayout active="exercicios">
      {exercisesQuery.isLoading && <StatusMessage message="Carregando exercícios…" />}

      {exercisesQuery.isError && (
        <StatusMessage
          message="Não foi possível carregar os exercícios agora."
          error={exercisesQuery.error}
          action={
            topicId
              ? { label: "Ver todos os exercícios", onClick: () => navigate("/exercicios") }
              : { label: "Tentar novamente", onClick: () => exercisesQuery.refetch() }
          }
        />
      )}

      {exercises && (
        <>
          <StyledPageTitle>Exercícios</StyledPageTitle>
          <StyledPageSubtitle>
            {topic
              ? `Aula ${topic.topicNumber} - ${topic.topicName} · ${topic.subjectName}`
              : "Listas de exercícios por assunto, sem limite de tempo."}
          </StyledPageSubtitle>
          {topicId && <StyledAllLink to="/exercicios">Ver todos os exercícios</StyledAllLink>}

          {exercises.length === 0 && (
            <StatusMessage
              message={
                topicId
                  ? "Ainda não há exercícios para este assunto."
                  : "Ainda não há exercícios publicados."
              }
            />
          )}

          {groupBySubject(exercises).map((group) => (
            <StyledSubjectSection key={group.subjectId} aria-label={group.subjectName}>
              {!topicId && <StyledSubjectTitle>{group.subjectName}</StyledSubjectTitle>}
              <StyledGrid>
                {group.exercises.map((exercise) => (
                  <StyledExerciseCard key={exercise.id}>
                    <Badge tone="accent">
                      Aula {exercise.topicNumber} - {exercise.topicName}
                    </Badge>
                    <StyledExerciseTitle>{exercise.title}</StyledExerciseTitle>
                    <StyledExerciseMeta>
                      {formatCount(exercise.questionCount, "questão", "questões")} ·{" "}
                      {formatCount(exercise.attemptsCount, "tentativa", "tentativas")} ·{" "}
                      {DIFFICULTY_LABEL[exercise.difficulty]}
                    </StyledExerciseMeta>
                    <StyledCardFooter>
                      <Button variant="secondary" onClick={() => setStartModalExercise(exercise)}>
                        Iniciar
                      </Button>
                    </StyledCardFooter>
                  </StyledExerciseCard>
                ))}
              </StyledGrid>
            </StyledSubjectSection>
          ))}
        </>
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
