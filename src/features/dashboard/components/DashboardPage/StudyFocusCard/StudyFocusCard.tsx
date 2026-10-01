import { useId, useLayoutEffect, useState } from "react";
import { useNavigate } from "react-router-dom";
import { Badge, type BadgeTone } from "@components/ui/Badge";
import { Button } from "@components/ui/Button";
import { ProgressBar } from "@components/ui/ProgressBar";
import type { DashboardData, StudyFocusLevel, StudyFocusTopic } from "@models/dashboard";
import { useElementSize } from "@features/dashboard/hooks/useElementSize";
import { formatPercent } from "@features/dashboard/percent";
import { formatCount } from "@utils/formatCount";
import {
  StyledStudyFocusCard,
  StyledTitle,
  StyledSubtitle,
  StyledList,
  StyledItem,
  StyledItemTop,
  StyledTopicName,
  StyledTopicMeta,
  StyledAccuracy,
  StyledAction,
  StyledMore,
  StyledEmpty,
} from "./StudyFocusCard.styles";

type StudyFocusCardProps = {
  studyFocus: DashboardData["studyFocus"];
};

const LEVEL_BADGE: Record<StudyFocusLevel, { tone: BadgeTone; label: string }> = {
  high: { tone: "danger", label: "▲ Alta" },
  medium: { tone: "accent2", label: "● Média" },
  few_practice: { tone: "neutral", label: "○ Pouco praticado" },
};

function nextStep(topic: StudyFocusTopic): string {
  if (topic.level === "high") return "Revisar o material e refazer as erradas";
  if (topic.level === "few_practice") return "Resolver 10 novas questões";
  if (topic.recentWrongCount > 0) {
    return `Refazer ${formatCount(topic.recentWrongCount, "questão errada recente", "questões erradas recentes")}`;
  }
  return "Fazer um mini-simulado";
}

export function StudyFocusCard({ studyFocus }: StudyFocusCardProps) {
  const titleId = useId();
  const navigate = useNavigate();
  const { ref, element, height } = useElementSize<HTMLUListElement>();
  const [visibleCount, setVisibleCount] = useState(studyFocus.items.length);
  const [first] = studyFocus.items;

  // Items that would be cut by the bottom of the card are hidden, never half shown.
  useLayoutEffect(() => {
    if (!element) return;
    const limit = element.getBoundingClientRect().bottom + 1;
    const items = Array.from(element.children);
    const fitting = items.filter((item) => item.getBoundingClientRect().bottom <= limit).length;
    setVisibleCount(Math.max(1, fitting));
  }, [element, height, studyFocus]);

  const hiddenCount = studyFocus.totalCount - Math.min(visibleCount, studyFocus.items.length);

  return (
    <StyledStudyFocusCard as="section" aria-labelledby={titleId}>
      <StyledTitle id={titleId}>O que estudar agora</StyledTitle>
      <StyledSubtitle>Assuntos que mais precisam de atenção</StyledSubtitle>

      {first ? (
        <>
          <StyledList ref={ref}>
            {studyFocus.items.map((topic, index) => {
              const badge = LEVEL_BADGE[topic.level];
              const hidden = index >= visibleCount;
              return (
                <StyledItem key={topic.topicId} $hidden={hidden} aria-hidden={hidden}>
                  <StyledItemTop>
                    <StyledTopicName>
                      {topic.topicName}
                      <StyledTopicMeta>
                        {topic.subjectShortLabel} · Aula {topic.topicNumber}
                      </StyledTopicMeta>
                    </StyledTopicName>
                    <Badge tone={badge.tone}>{badge.label}</Badge>
                  </StyledItemTop>
                  <StyledAccuracy>
                    <ProgressBar
                      value={topic.percent ?? 0}
                      label={`Acerto em ${topic.topicName}`}
                    />
                    <b>{formatPercent(topic.percent)}</b>
                  </StyledAccuracy>
                  <StyledAction>→ {nextStep(topic)}</StyledAction>
                </StyledItem>
              );
            })}
          </StyledList>
          {hiddenCount > 0 && (
            <StyledMore>
              + {formatCount(hiddenCount, "assunto", "assuntos")} para revisar depois
            </StyledMore>
          )}
          <Button onClick={() => navigate(`/disciplinas/${first.subjectId}`)}>
            Começar pelo primeiro
          </Button>
        </>
      ) : (
        <StyledEmpty>Tudo acima da meta neste período. Continue assim! 🎉</StyledEmpty>
      )}
    </StyledStudyFocusCard>
  );
}
