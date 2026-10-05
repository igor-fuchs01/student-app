import { useState } from "react";
import { useNavigate, useSearchParams } from "react-router-dom";
import { useQuery } from "@tanstack/react-query";
import { Badge, type BadgeTone } from "@components/ui/Badge";
import { Button } from "@components/ui/Button";
import { StatusMessage } from "@components/ui/StatusMessage";
import { PageLayout } from "@components/layout/PageLayout";
import { StartQuizModal } from "@features/quizzes/components/StartQuizModal";
import { DIFFICULTY_LABEL } from "@features/quizzes/difficultyLabel";
import { quizzesApi } from "@services/api/quizzesApi";
import type { ExerciseSummary, QuizDifficulty } from "@models/quizzes";
import { formatCount } from "@utils/formatCount";
import {
  StyledPageTitle,
  StyledPageSubtitle,
  StyledAllLink,
  StyledSubjectSection,
  StyledSubjectTitle,
  StyledTopicSection,
  StyledTopicHeader,
  StyledTopicTitle,
  StyledTopicName,
  StyledGrid,
  StyledExerciseCard,
  StyledExerciseTitle,
  StyledExerciseMeta,
  StyledCardFooter,
} from "./ExercisesPage.styles";

type TopicGroup = {
  topicId: string;
  topicNumber: number;
  topicName: string;
  exercises: ExerciseSummary[];
};

type SubjectGroup = { subjectId: string; subjectName: string; topics: TopicGroup[] };

const DIFFICULTY_TONE: Record<QuizDifficulty, BadgeTone> = {
  easy: "accent",
  medium: "accent2",
  hard: "danger",
};

// Groups the lists by subject and, inside it, by lesson (aula), whatever their difficulty. The API
// already orders them by subject, lesson and title, so grouping keeps that order.
function groupBySubjectAndTopic(exercises: ExerciseSummary[]): SubjectGroup[] {
  const subjects: SubjectGroup[] = [];

  for (const exercise of exercises) {
    let subject = subjects.find((item) => item.subjectId === exercise.subjectId);
    if (!subject) {
      subject = { subjectId: exercise.subjectId, subjectName: exercise.subjectName, topics: [] };
      subjects.push(subject);
    }

    let topic = subject.topics.find((item) => item.topicId === exercise.topicId);
    if (!topic) {
      topic = {
        topicId: exercise.topicId,
        topicNumber: exercise.topicNumber,
        topicName: exercise.topicName,
        exercises: [],
      };
      subject.topics.push(topic);
    }

    topic.exercises.push(exercise);
  }

  return subjects;
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
              : "Listas de exercícios de cada aula, sem limite de tempo."}
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

          {groupBySubjectAndTopic(exercises).map((subject) => (
            <StyledSubjectSection key={subject.subjectId} aria-label={subject.subjectName}>
              {!topicId && <StyledSubjectTitle>{subject.subjectName}</StyledSubjectTitle>}

              {subject.topics.map((topicGroup) => (
                <StyledTopicSection
                  key={topicGroup.topicId}
                  aria-label={`Exercícios da Aula ${topicGroup.topicNumber}`}
                >
                  <StyledTopicHeader>
                    <StyledTopicTitle>Exercícios da Aula {topicGroup.topicNumber}</StyledTopicTitle>
                    <StyledTopicName>
                      {topicGroup.topicName} ·{" "}
                      {formatCount(topicGroup.exercises.length, "lista", "listas")}
                    </StyledTopicName>
                  </StyledTopicHeader>

                  <StyledGrid>
                    {topicGroup.exercises.map((exercise) => (
                      <StyledExerciseCard key={exercise.id}>
                        <Badge tone={DIFFICULTY_TONE[exercise.difficulty]}>
                          {DIFFICULTY_LABEL[exercise.difficulty]}
                        </Badge>
                        <StyledExerciseTitle>{exercise.title}</StyledExerciseTitle>
                        <StyledExerciseMeta>
                          Aula {exercise.topicNumber} ·{" "}
                          {formatCount(exercise.questionCount, "questão", "questões")} ·{" "}
                          {formatCount(exercise.attemptsCount, "tentativa", "tentativas")}
                        </StyledExerciseMeta>
                        <StyledCardFooter>
                          <Button
                            variant="secondary"
                            onClick={() => setStartModalExercise(exercise)}
                          >
                            Iniciar
                          </Button>
                        </StyledCardFooter>
                      </StyledExerciseCard>
                    ))}
                  </StyledGrid>
                </StyledTopicSection>
              ))}
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
