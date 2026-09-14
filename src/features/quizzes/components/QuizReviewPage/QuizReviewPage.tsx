import { useState } from "react";
import { useNavigate } from "react-router-dom";
import { Button } from "@components/ui/Button";
import { Modal } from "@components/ui/Modal";
import { useQuizAttemptContext } from "../QuizAttemptLayout";
import { isQuestionAnswered } from "../../isQuestionAnswered";
import {
  StyledContent,
  StyledTitle,
  StyledSubtitle,
  StyledCountRow,
  StyledCountBadge,
  StyledGrid,
  StyledTile,
  StyledLegend,
  StyledLegendItem,
  StyledLegendDot,
  StyledFooter,
  StyledConfirmTitle,
  StyledConfirmBody,
  StyledConfirmActions,
  StyledErrorMessage,
} from "./QuizReviewPage.styles";

export function QuizReviewPage() {
  const navigate = useNavigate();
  const {
    quiz,
    answers,
    markedForReview,
    setCurrentIndex,
    submit,
    isSubmitting,
    submitError,
  } = useQuizAttemptContext();
  const [confirmOpen, setConfirmOpen] = useState(false);

  function isAnswered(questionId: string): boolean {
    const question = quiz.questions.find((q) => q.id === questionId);
    return question ? isQuestionAnswered(question, answers[questionId]) : false;
  }

  const answeredCount = quiz.questions.filter((q) => isAnswered(q.id)).length;
  const unansweredCount = quiz.questions.length - answeredCount;
  const markedCount = markedForReview.size;

  function goToQuestion(index: number) {
    setCurrentIndex(index);
    navigate(`/simulados/${quiz.id}`);
  }

  return (
    <StyledContent>
      <StyledTitle>Revisar antes de enviar</StyledTitle>
      <StyledSubtitle>{quiz.title}</StyledSubtitle>

      <StyledCountRow>
        <StyledCountBadge $tone="neutral">{answeredCount} respondidas</StyledCountBadge>
        <StyledCountBadge $tone="danger">{unansweredCount} não respondidas</StyledCountBadge>
        <StyledCountBadge $tone="accent">{markedCount} marcadas para revisão</StyledCountBadge>
      </StyledCountRow>

      <StyledGrid>
        {quiz.questions.map((q, index) => (
          <StyledTile
            key={q.id}
            type="button"
            $answered={isAnswered(q.id)}
            $marked={markedForReview.has(q.id)}
            onClick={() => goToQuestion(index)}
          >
            {index + 1}
          </StyledTile>
        ))}
      </StyledGrid>

      <StyledLegend>
        <StyledLegendItem>
          <StyledLegendDot $tone="answered" />
          Respondida
        </StyledLegendItem>
        <StyledLegendItem>
          <StyledLegendDot $tone="marked" />
          Marcada para revisão
        </StyledLegendItem>
        <StyledLegendItem>
          <StyledLegendDot $tone="empty" />
          Não respondida
        </StyledLegendItem>
      </StyledLegend>

      <StyledFooter>
        <Button variant="secondary" onClick={() => navigate(`/simulados/${quiz.id}`)}>
          Voltar a responder
        </Button>
        <Button variant="primary" onClick={() => setConfirmOpen(true)}>
          Enviar simulado
        </Button>
      </StyledFooter>

      {confirmOpen && (
        <Modal ariaLabel="Confirmar envio do simulado">
          <StyledConfirmTitle>Enviar simulado?</StyledConfirmTitle>
          <StyledConfirmBody>
            {unansweredCount > 0 ? (
              <>
                Você tem <strong>{unansweredCount} questões não respondidas</strong>. Elas
                serão consideradas incorretas na correção. Esta ação não pode ser desfeita.
              </>
            ) : (
              <>Esta ação não pode ser desfeita.</>
            )}
          </StyledConfirmBody>
          {submitError && <StyledErrorMessage role="alert">{submitError}</StyledErrorMessage>}
          <StyledConfirmActions>
            <Button
              variant="secondary"
              onClick={() => setConfirmOpen(false)}
              disabled={isSubmitting}
            >
              Continuar respondendo
            </Button>
            <Button variant="primary" onClick={submit} isLoading={isSubmitting}>
              Confirmar envio
            </Button>
          </StyledConfirmActions>
        </Modal>
      )}
    </StyledContent>
  );
}
