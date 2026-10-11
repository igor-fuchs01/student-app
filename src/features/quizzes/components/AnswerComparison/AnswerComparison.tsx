import {
  StyledAnswerComparison,
  StyledAnswerLabel,
  StyledAnswerText,
} from "./AnswerComparison.styles";

type AnswerComparisonProps = {
  studentAnswer: string;
  referenceAnswer: string;
};

export function AnswerComparison({ studentAnswer, referenceAnswer }: AnswerComparisonProps) {
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
    </StyledAnswerComparison>
  );
}
