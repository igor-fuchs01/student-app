import type { ReactNode } from "react";
import {
  StyledAnswerComparison,
  StyledAnswerLabel,
  StyledAnswerText,
} from "./AnswerComparison.styles";

type AnswerComparisonProps = {
  studentAnswer: string;
  referenceAnswer: string;
  children?: ReactNode;
};

export function AnswerComparison({
  studentAnswer,
  referenceAnswer,
  children,
}: AnswerComparisonProps) {
  return (
    <StyledAnswerComparison>
      <div>
        <StyledAnswerLabel>Sua resposta</StyledAnswerLabel>
        <StyledAnswerText>{studentAnswer}</StyledAnswerText>
      </div>
      <div>
        <StyledAnswerLabel>Resposta esperada</StyledAnswerLabel>
        <StyledAnswerText>{referenceAnswer}</StyledAnswerText>
      </div>
      {children}
    </StyledAnswerComparison>
  );
}
