import { useState } from "react";
import { useNavigate } from "react-router-dom";
import { Badge } from "@components/ui/Badge";
import { Button } from "@components/ui/Button";
import { Modal } from "@components/ui/Modal";
import {
  QuestionGrid,
  type QuestionGridLegendItem,
} from "@features/quizzes/components/QuestionGrid";
import { useQuizAttemptContext } from "@features/quizzes/hooks/useQuizAttemptContext";
import { isQuestionAnswered } from "@features/quizzes/isQuestionAnswered";
import {
  StyledContent,
  StyledTitle,
  StyledSubtitle,
  StyledCountRow,
  StyledFooter,
  StyledConfirmTitle,
  StyledConfirmBody,
  StyledConfirmActions,
  StyledErrorMessage,
} from "./QuizReviewPage.styles";

const LEGEND: QuestionGridLegendItem[] = [
  { label: "Respondida", tone: "answered" },
  { label: "Marcada para revisão", tone: "empty", marked: true },
  { label: "Não respondida", tone: "empty" },
];

export function QuizReviewPage() {
  const navigate = useNavigate();
  const { quiz, answers, markedForReview, setCurrentIndex, submit, isSubmitting, submitError } =
    useQuizAttemptContext();
  const [confirmOpen, setConfirmOpen] = useState(false);

  const answeredIds = new Set(
    quiz.questions.filter((q) => isQuestionAnswered(q, answers[q.id])).map((q) => q.id),
  );
  const unansweredCount = quiz.questions.length - answeredIds.size;

  function goToQuestion(index: number) {
    setCurrentIndex(index);
    navigate(`/simulados/${quiz.id}`);
  }

  return (
    <StyledContent>
      <StyledTitle>Revisar antes de enviar</StyledTitle>
      <StyledSubtitle>{quiz.title}</StyledSubtitle>

      <StyledCountRow>
        <Badge tone="neutral">{answeredIds.size} respondidas</Badge>
        <Badge tone="danger">{unansweredCount} não respondidas</Badge>
        <Badge tone="accent">{markedForReview.size} marcadas para revisão</Badge>
      </StyledCountRow>

      <QuestionGrid
        variant="wide"
        tiles={quiz.questions.map((q) => ({
          id: q.id,
          tone: answeredIds.has(q.id) ? "answered" : "empty",
          marked: markedForReview.has(q.id),
        }))}
        legend={LEGEND}
        onSelect={goToQuestion}
      />

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
                Você tem <strong>{unansweredCount} questões não respondidas</strong>. Elas serão
                consideradas incorretas na correção. Esta ação não pode ser desfeita.
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
