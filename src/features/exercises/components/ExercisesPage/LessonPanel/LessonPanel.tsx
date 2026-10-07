import { useId, useState } from "react";
import { Button } from "@components/ui/Button";
import { ProgressBar } from "@components/ui/ProgressBar";
import { countDone, isExerciseDone, type LessonGroup } from "@features/exercises/groupExercises";
import type { ExerciseSummary } from "@models/quizzes";
import type { SubjectTopic } from "@models/subjects";
import { formatCount } from "@utils/formatCount";
import {
  StyledPanel,
  StyledBackButton,
  StyledEyebrow,
  StyledLessonName,
  StyledProgress,
  StyledProgressLabel,
  StyledSection,
  StyledSectionTitle,
  StyledSummary,
  StyledMuted,
  StyledKeyPointsToggle,
  StyledKeyPoints,
  StyledExerciseList,
  StyledExerciseRow,
  StyledExerciseInfo,
  StyledExerciseTitle,
  StyledExerciseMeta,
} from "./LessonPanel.styles";

type LessonPanelProps = {
  subjectName: string;
  lesson: LessonGroup;
  // The lesson's content from GET /subjects/:id; undefined while it loads or when it failed.
  content: SubjectTopic | undefined;
  contentStatus: "pending" | "error" | "success";
  onStart: (exercise: ExerciseSummary) => void;
  onBack: () => void;
};

export function LessonPanel({
  subjectName,
  lesson,
  content,
  contentStatus,
  onStart,
  onBack,
}: LessonPanelProps) {
  const [keyPointsOpen, setKeyPointsOpen] = useState(false);
  const keyPointsId = useId();
  const done = countDone(lesson);
  const total = lesson.exercises.length;
  const keyPoints = content?.subtopics.flatMap((subtopic) => subtopic.keyPoints) ?? [];

  return (
    <StyledPanel aria-labelledby={`lesson-${lesson.topicId}`}>
      <StyledBackButton type="button" onClick={onBack}>
        ← Aulas
      </StyledBackButton>

      <StyledEyebrow>
        Aula {lesson.topicNumber} · {subjectName}
      </StyledEyebrow>
      <StyledLessonName id={`lesson-${lesson.topicId}`}>{lesson.topicName}</StyledLessonName>

      <StyledProgress>
        <ProgressBar
          value={(done / total) * 100}
          label={`Listas feitas da Aula ${lesson.topicNumber}`}
        />
        <StyledProgressLabel>
          {done} de {formatCount(total, "lista feita", "listas feitas")}
        </StyledProgressLabel>
      </StyledProgress>

      <StyledSection>
        <StyledSectionTitle>Resumo da aula</StyledSectionTitle>
        {contentStatus === "pending" && <StyledMuted>Carregando o resumo…</StyledMuted>}
        {contentStatus === "error" && (
          <StyledMuted>
            Não foi possível carregar o resumo agora. As listas continuam abaixo.
          </StyledMuted>
        )}
        {content && <StyledSummary>{content.description}</StyledSummary>}
        {contentStatus === "success" && !content && (
          <StyledMuted>Esta aula ainda não tem resumo.</StyledMuted>
        )}
        {keyPoints.length > 0 && (
          <>
            <StyledKeyPointsToggle
              type="button"
              aria-expanded={keyPointsOpen}
              aria-controls={keyPointsId}
              onClick={() => setKeyPointsOpen((open) => !open)}
            >
              {keyPointsOpen ? "▾ Ocultar" : "▸ Ver"} pontos-chave ({keyPoints.length})
            </StyledKeyPointsToggle>
            <StyledKeyPoints id={keyPointsId} hidden={!keyPointsOpen}>
              {keyPoints.map((keyPoint) => (
                <li key={keyPoint}>{keyPoint}</li>
              ))}
            </StyledKeyPoints>
          </>
        )}
      </StyledSection>

      <StyledSection>
        <StyledSectionTitle>Listas de exercícios</StyledSectionTitle>
        <StyledExerciseList>
          {lesson.exercises.map((exercise) => (
            <StyledExerciseRow key={exercise.id}>
              <StyledExerciseInfo>
                <StyledExerciseTitle>{exercise.title}</StyledExerciseTitle>
                <StyledExerciseMeta>
                  {formatCount(exercise.questionCount, "questão", "questões")} ·{" "}
                  {isExerciseDone(exercise) ? `✓ Feita ${exercise.attemptsCount}×` : "Não feita"}
                </StyledExerciseMeta>
              </StyledExerciseInfo>
              <Button variant="secondary" onClick={() => onStart(exercise)}>
                {isExerciseDone(exercise) ? "Refazer" : "Iniciar"}
              </Button>
            </StyledExerciseRow>
          ))}
        </StyledExerciseList>
      </StyledSection>
    </StyledPanel>
  );
}
