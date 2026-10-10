import { useId, useState, type KeyboardEvent } from "react";
import { Badge } from "@components/ui/Badge";
import { Button } from "@components/ui/Button";
import { countDone, isExerciseDone, type LessonGroup } from "@features/exercises/groupExercises";
import type { ExerciseSummary } from "@models/quizzes";
import type { SubjectTopic } from "@models/subjects";
import { formatCount } from "@utils/formatCount";
import {
  StyledPanel,
  StyledBackButton,
  StyledHeader,
  StyledLessonName,
  StyledProgress,
  StyledTabList,
  StyledTab,
  StyledTabPanel,
  StyledExerciseGrid,
  StyledExerciseCard,
  StyledExerciseTitle,
  StyledExerciseInfo,
  StyledExerciseMeta,
  StyledSummary,
  StyledMuted,
  StyledKeyPointsTitle,
  StyledKeyPoints,
} from "./LessonPanel.styles";

type Tab = "lists" | "summary";

type LessonPanelProps = {
  lesson: LessonGroup;
  // The lesson's content from GET /subjects/:id; undefined while it loads or when it failed.
  content: SubjectTopic | undefined;
  contentStatus: "pending" | "error" | "success";
  onStart: (exercise: ExerciseSummary) => void;
  onBack: () => void;
};

export function LessonPanel({ lesson, content, contentStatus, onStart, onBack }: LessonPanelProps) {
  const [tab, setTab] = useState<Tab>("lists");
  const tabsId = useId();
  const done = countDone(lesson);
  const total = lesson.exercises.length;
  const keyPoints = content?.subtopics.flatMap((subtopic) => subtopic.keyPoints) ?? [];
  // Only the next list to do gets the filled button, so the panel has a single main action.
  const nextExercise = lesson.exercises.find((exercise) => !isExerciseDone(exercise));

  // With only two tabs, both arrow keys move to the other one, as in the WAI-ARIA tabs pattern.
  function handleTabKeyDown(event: KeyboardEvent<HTMLDivElement>) {
    if (event.key !== "ArrowLeft" && event.key !== "ArrowRight") return;
    const nextTab: Tab = tab === "lists" ? "summary" : "lists";
    setTab(nextTab);
    document.getElementById(`${tabsId}-${nextTab}-tab`)?.focus();
  }

  function tabProps(value: Tab) {
    return {
      id: `${tabsId}-${value}-tab`,
      type: "button" as const,
      role: "tab",
      "aria-selected": tab === value,
      "aria-controls": `${tabsId}-${value}-panel`,
      tabIndex: tab === value ? 0 : -1,
      $active: tab === value,
      onClick: () => setTab(value),
    };
  }

  function tabPanelProps(value: Tab) {
    return {
      id: `${tabsId}-${value}-panel`,
      role: "tabpanel",
      "aria-labelledby": `${tabsId}-${value}-tab`,
      hidden: tab !== value,
    };
  }

  return (
    <StyledPanel aria-labelledby={`lesson-${lesson.topicId}`}>
      <StyledBackButton type="button" onClick={onBack}>
        ← Aulas
      </StyledBackButton>

      <StyledHeader>
        <StyledLessonName id={`lesson-${lesson.topicId}`}>
          Aula {lesson.topicNumber} · {lesson.topicName}
        </StyledLessonName>
        <StyledProgress>
          <strong>{done}</strong> de {formatCount(total, "lista feita", "listas feitas")}
        </StyledProgress>
      </StyledHeader>

      <StyledTabList role="tablist" aria-label="Conteúdo da aula" onKeyDown={handleTabKeyDown}>
        <StyledTab {...tabProps("lists")}>
          Listas <span>({total})</span>
        </StyledTab>
        <StyledTab {...tabProps("summary")}>Resumo da aula</StyledTab>
      </StyledTabList>

      <StyledTabPanel {...tabPanelProps("lists")}>
        <StyledExerciseGrid>
          {lesson.exercises.map((exercise) => (
            <StyledExerciseCard key={exercise.id}>
              <StyledExerciseTitle>{exercise.title}</StyledExerciseTitle>
              <StyledExerciseInfo>
                <StyledExerciseMeta>
                  {formatCount(exercise.questionCount, "questão", "questões")}
                </StyledExerciseMeta>
                {isExerciseDone(exercise) ? (
                  <Badge tone="accent">✓ Feita {exercise.attemptsCount}×</Badge>
                ) : (
                  <Badge>Não feita</Badge>
                )}
              </StyledExerciseInfo>
              <Button
                variant={exercise === nextExercise ? "primary" : "secondary"}
                onClick={() => onStart(exercise)}
              >
                {isExerciseDone(exercise) ? "Refazer" : "Iniciar"}
              </Button>
            </StyledExerciseCard>
          ))}
        </StyledExerciseGrid>
      </StyledTabPanel>

      <StyledTabPanel {...tabPanelProps("summary")}>
        {contentStatus === "pending" && <StyledMuted>Carregando o resumo…</StyledMuted>}
        {contentStatus === "error" && (
          <StyledMuted>
            Não foi possível carregar o resumo agora. As listas continuam na outra aba.
          </StyledMuted>
        )}
        {content && <StyledSummary>{content.description}</StyledSummary>}
        {contentStatus === "success" && !content && (
          <StyledMuted>Esta aula ainda não tem resumo.</StyledMuted>
        )}
        {keyPoints.length > 0 && (
          <>
            <StyledKeyPointsTitle>Pontos-chave</StyledKeyPointsTitle>
            <StyledKeyPoints>
              {keyPoints.map((keyPoint) => (
                <li key={keyPoint}>{keyPoint}</li>
              ))}
            </StyledKeyPoints>
          </>
        )}
      </StyledTabPanel>
    </StyledPanel>
  );
}
