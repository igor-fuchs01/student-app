import { useId, useLayoutEffect, useState } from "react";
import { useNavigate } from "react-router-dom";
import { Button } from "@components/ui/Button";
import type { DashboardData, StudyFocusTopic } from "@models/dashboard";
import { useElementSize } from "@features/dashboard/hooks/useElementSize";
import { formatPercent } from "@features/dashboard/percent";
import { formatCount } from "@utils/formatCount";
import {
  StyledStudyFocusCard,
  StyledTitle,
  StyledHighlight,
  StyledHighlightName,
  StyledTopicMeta,
  StyledAction,
  StyledNextLabel,
  StyledList,
  StyledItem,
  StyledTopicName,
  StyledPercent,
  StyledMore,
  StyledEmpty,
} from "./StudyFocusCard.styles";

type StudyFocusCardProps = {
  studyFocus: DashboardData["studyFocus"];
};

// One clear starting point plus a short queue keeps the card readable at a glance.
const NEXT_LIMIT = 2;

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
  const [first, ...rest] = studyFocus.items;
  const next = rest.slice(0, NEXT_LIMIT);
  const [visibleCount, setVisibleCount] = useState(next.length);

  // Items that would be cut by the bottom of the card are hidden, never half shown.
  useLayoutEffect(() => {
    if (!element) return;
    const limit = element.getBoundingClientRect().bottom + 1;
    const items = Array.from(element.children);
    setVisibleCount(items.filter((item) => item.getBoundingClientRect().bottom <= limit).length);
  }, [element, height, studyFocus]);

  const hiddenCount = studyFocus.totalCount - 1 - Math.min(visibleCount, next.length);

  return (
    <StyledStudyFocusCard as="section" aria-labelledby={titleId}>
      <StyledTitle id={titleId}>O que estudar agora</StyledTitle>

      {first ? (
        <>
          <StyledHighlight>
            <StyledHighlightName>{first.topicName}</StyledHighlightName>
            <StyledTopicMeta>
              {first.subjectShortLabel} · Aula {first.topicNumber} · acerto{" "}
              {formatPercent(first.percent)}
            </StyledTopicMeta>
            <StyledAction>{nextStep(first)}</StyledAction>
            <Button onClick={() => navigate(`/disciplinas/${first.subjectId}`)}>
              Estudar agora
            </Button>
          </StyledHighlight>

          {next.length > 0 && <StyledNextLabel>Em seguida</StyledNextLabel>}
          <StyledList ref={ref}>
            {next.map((topic, index) => {
              const hidden = index >= visibleCount;
              return (
                <StyledItem key={topic.topicId} $hidden={hidden} aria-hidden={hidden}>
                  <StyledTopicName title={topic.topicName}>{topic.topicName}</StyledTopicName>
                  <StyledPercent>{formatPercent(topic.percent)}</StyledPercent>
                </StyledItem>
              );
            })}
          </StyledList>
          {hiddenCount > 0 && (
            <StyledMore>
              + {formatCount(hiddenCount, "assunto", "assuntos")} para revisar depois
            </StyledMore>
          )}
        </>
      ) : (
        <StyledEmpty>Tudo acima da meta neste período. Continue assim! 🎉</StyledEmpty>
      )}
    </StyledStudyFocusCard>
  );
}
