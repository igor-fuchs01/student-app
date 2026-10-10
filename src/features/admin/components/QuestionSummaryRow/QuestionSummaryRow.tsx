import type { ReactNode } from "react";
import { Badge } from "@components/ui/Badge";
import { QUESTION_TYPE_LABEL } from "@features/admin/questionDraft";
import type { AdminQuestionSummary } from "@models/admin";
import { formatCount } from "@utils/formatCount";
import {
  StyledRow,
  StyledText,
  StyledStatement,
  StyledMeta,
  StyledActions,
} from "./QuestionSummaryRow.styles";

type QuestionSummaryRowProps = {
  question: AdminQuestionSummary;
  position?: number;
  actions: ReactNode;
};

export function QuestionSummaryRow({ question, position, actions }: QuestionSummaryRowProps) {
  return (
    <StyledRow>
      <StyledText>
        <StyledStatement>
          {position !== undefined && `${position}. `}
          {question.statement}
        </StyledStatement>
        <StyledMeta>
          <Badge tone="accent">{QUESTION_TYPE_LABEL[question.type]}</Badge>
          <span>
            {question.subjectName} · Aula {question.topicNumber} — {question.topicName}
          </span>
          <span>· em {formatCount(question.quizCount, "simulado/lista", "simulados/listas")}</span>
          {question.answered && <Badge tone="accent2">Já respondida</Badge>}
        </StyledMeta>
      </StyledText>
      <StyledActions>{actions}</StyledActions>
    </StyledRow>
  );
}
