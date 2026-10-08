import { useId, useState } from "react";
import { useNavigate } from "react-router-dom";
import { Badge } from "@components/ui/Badge";
import { Button } from "@components/ui/Button";
import { Modal } from "@components/ui/Modal";
import type { DashboardData, StudyFocusLevel, StudyFocusTopic } from "@models/dashboard";
import { formatPercent, PREPARATION_TARGET } from "@features/dashboard/percent";
import { formatCount } from "@utils/formatCount";
import {
  StyledStudyFocusCard,
  StyledTitle,
  StyledTopic,
  StyledTopicName,
  StyledTopicMeta,
  StyledSectionLabel,
  StyledWhy,
  StyledAccuracyTrack,
  StyledAccuracyFill,
  StyledTargetMark,
  StyledScale,
  StyledReason,
  StyledNextStep,
  StyledNextStepText,
  StyledFooter,
  StyledLinkButton,
  StyledModalTitle,
  StyledModalNote,
  StyledOtherList,
  StyledOtherItem,
  StyledOtherName,
  StyledOtherReason,
  StyledModalActions,
  StyledEmpty,
} from "./StudyFocusCard.styles";

type StudyFocusCardProps = {
  studyFocus: DashboardData["studyFocus"];
};

const RECENT_DAYS = 14;
const MINUTES_PER_QUESTION = 2;
const REVIEW_MINUTES = 10;
const PRACTICE_QUESTIONS = 10;

const LEVELS: Record<StudyFocusLevel, { label: string; tone: "danger" | "accent2" | "neutral" }> = {
  high: { label: "Prioridade alta", tone: "danger" },
  medium: { label: "Prioridade média", tone: "accent2" },
  few_practice: { label: "Pouca prática", tone: "neutral" },
};

function reason(topic: StudyFocusTopic): string {
  if (topic.level === "few_practice") {
    return topic.gradedCount === 0
      ? "Você ainda não resolveu questões deste assunto no período."
      : `Você resolveu só ${formatCount(topic.gradedCount, "questão", "questões")} deste assunto no período.`;
  }
  if (topic.recentWrongCount > 0) {
    return `Você errou ${formatCount(topic.recentWrongCount, "questão", "questões")} deste assunto nos últimos ${RECENT_DAYS} dias.`;
  }
  return `Seu acerto ainda está abaixo da meta de ${PREPARATION_TARGET}%.`;
}

function nextStep(topic: StudyFocusTopic): { text: string; minutes: number } {
  const wrong = topic.recentWrongCount;
  const practice = {
    text: `Resolver ${PRACTICE_QUESTIONS} questões novas`,
    minutes: PRACTICE_QUESTIONS * MINUTES_PER_QUESTION,
  };
  if (topic.level === "few_practice") return practice;
  if (topic.level === "high") {
    return wrong > 0
      ? {
          text: `Revisar o material da aula e refazer ${formatCount(wrong, "questão errada", "questões erradas")}`,
          minutes: REVIEW_MINUTES + wrong * MINUTES_PER_QUESTION,
        }
      : { text: "Revisar o material da aula e refazer as erradas", minutes: 2 * REVIEW_MINUTES };
  }
  return wrong > 0
    ? {
        text: `Refazer ${formatCount(wrong, "questão errada recente", "questões erradas recentes")}`,
        minutes: wrong * MINUTES_PER_QUESTION,
      }
    : { text: "Fazer um mini-simulado", minutes: practice.minutes };
}

function topicMeta(topic: StudyFocusTopic): string {
  return `${topic.subjectShortLabel} · Aula ${topic.topicNumber}`;
}

export function StudyFocusCard({ studyFocus }: StudyFocusCardProps) {
  const titleId = useId();
  const navigate = useNavigate();
  const [showOthers, setShowOthers] = useState(false);
  const [first, ...others] = studyFocus.items;
  const othersCount = studyFocus.totalCount - 1;

  if (!first) {
    return (
      <StyledStudyFocusCard as="section" aria-labelledby={titleId}>
        <StyledTitle id={titleId}>O que estudar agora</StyledTitle>
        <StyledEmpty>Tudo acima da meta neste período. Continue assim! 🎉</StyledEmpty>
      </StyledStudyFocusCard>
    );
  }

  const level = LEVELS[first.level];
  const step = nextStep(first);

  return (
    <StyledStudyFocusCard as="section" aria-labelledby={titleId}>
      <StyledTitle id={titleId}>O que estudar agora</StyledTitle>

      <StyledTopic>
        <Badge tone={level.tone}>{level.label}</Badge>
        <StyledTopicName>{first.topicName}</StyledTopicName>
        <StyledTopicMeta>{topicMeta(first)}</StyledTopicMeta>
      </StyledTopic>

      <StyledWhy>
        <StyledSectionLabel>Por que agora</StyledSectionLabel>
        {first.percent !== null && (
          <>
            <StyledAccuracyTrack
              role="img"
              aria-label={`Acerto de ${formatPercent(first.percent)}, meta de ${PREPARATION_TARGET}%`}
            >
              <StyledAccuracyFill $value={first.percent} $level={first.level} />
              <StyledTargetMark $value={PREPARATION_TARGET} />
            </StyledAccuracyTrack>
            <StyledScale aria-hidden>
              <span>
                Seu acerto: <strong>{formatPercent(first.percent)}</strong>
              </span>
              <span>Meta: {PREPARATION_TARGET}%</span>
            </StyledScale>
          </>
        )}
        <StyledReason>{reason(first)}</StyledReason>
      </StyledWhy>

      <StyledNextStep>
        <StyledSectionLabel>Próximo passo · cerca de {step.minutes} min</StyledSectionLabel>
        <StyledNextStepText>{step.text}</StyledNextStepText>
        <Button onClick={() => navigate(`/disciplinas/${first.subjectId}`)}>Estudar agora</Button>
      </StyledNextStep>

      {othersCount > 0 && others.length > 0 && (
        <StyledFooter>
          <StyledLinkButton type="button" onClick={() => setShowOthers(true)}>
            Ver {othersCount === 1 ? "o outro assunto" : `os outros ${othersCount} assuntos`} →
          </StyledLinkButton>
        </StyledFooter>
      )}

      {showOthers && (
        <Modal ariaLabel="Outros assuntos para estudar" onClose={() => setShowOthers(false)}>
          <StyledModalTitle>Outros assuntos para estudar</StyledModalTitle>
          {othersCount > others.length && (
            <StyledModalNote>
              Mostrando os {others.length} de maior prioridade entre {othersCount}.
            </StyledModalNote>
          )}
          <StyledOtherList>
            {others.map((topic) => (
              <li key={topic.topicId}>
                <StyledOtherItem
                  type="button"
                  onClick={() => navigate(`/disciplinas/${topic.subjectId}`)}
                >
                  <StyledOtherName>
                    {topic.topicName}
                    <Badge tone={LEVELS[topic.level].tone}>{LEVELS[topic.level].label}</Badge>
                  </StyledOtherName>
                  <StyledOtherReason>
                    {topicMeta(topic)} · {reason(topic)}
                  </StyledOtherReason>
                </StyledOtherItem>
              </li>
            ))}
          </StyledOtherList>
          <StyledModalActions>
            <Button variant="secondary" onClick={() => setShowOthers(false)}>
              Fechar
            </Button>
          </StyledModalActions>
        </Modal>
      )}
    </StyledStudyFocusCard>
  );
}
