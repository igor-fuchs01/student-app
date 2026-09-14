import { useNavigate } from "react-router-dom";
import { Button } from "@components/ui/Button";
import { useQuizAttemptContext } from "@features/quizzes/hooks/useQuizAttemptContext";
import { isQuestionAnswered } from "../../isQuestionAnswered";
import { QuestionField } from "@features/quizzes/components/QuestionField";
import {
  StyledContent,
  StyledTopBar,
  StyledTopBarTitle,
  StyledTopBarMeta,
  StyledQuestionCount,
  StyledTimer,
  StyledTimerToggle,
  StyledLayout,
  StyledQuestionCard,
  StyledSidebar,
  StyledSidebarHeader,
  StyledSidebarLabel,
  StyledMarkCurrentButton,
  StyledQuestionGrid,
  StyledQuestionTile,
  StyledLegend,
  StyledLegendItem,
  StyledLegendDot,
  StyledFooter,
} from "./QuizAnsweringPage.styles";

function formatClock(totalSeconds: number): string {
  const minutes = Math.floor(totalSeconds / 60);
  const seconds = totalSeconds % 60;
  return `${String(minutes).padStart(2, "0")}:${String(seconds).padStart(2, "0")}`;
}

export function QuizAnsweringPage() {
  const navigate = useNavigate();
  const {
    quiz,
    currentIndex,
    setCurrentIndex,
    answers,
    setAnswer,
    markedForReview,
    toggleMarkedForReview,
    timeLimitEnabled,
    remainingSeconds,
    elapsedSeconds,
    showTimer,
    toggleShowTimer,
  } = useQuizAttemptContext();

  const question = quiz.questions[currentIndex];
  const isLast = currentIndex === quiz.questions.length - 1;
  const isMarked = markedForReview.has(question.id);

  function goNext() {
    if (isLast) {
      navigate(`/simulados/${quiz.id}/revisao`);
    } else {
      setCurrentIndex(currentIndex + 1);
    }
  }

  function goBack() {
    if (currentIndex > 0) setCurrentIndex(currentIndex - 1);
  }

  return (
    <StyledContent>
      <StyledTopBar>
        <StyledTopBarTitle>{quiz.title}</StyledTopBarTitle>
        <StyledTopBarMeta>
          <StyledQuestionCount>
            Questão {currentIndex + 1} de {quiz.questions.length}
          </StyledQuestionCount>
          <StyledTimer>
            ⏱{" "}
            {showTimer
              ? formatClock(timeLimitEnabled ? remainingSeconds : elapsedSeconds)
              : "--:--"}
          </StyledTimer>
          <StyledTimerToggle
            type="button"
            onClick={toggleShowTimer}
            aria-label={showTimer ? "Ocultar tempo" : "Mostrar tempo"}
            title={showTimer ? "Ocultar tempo" : "Mostrar tempo"}
          >
            {showTimer ? "👁" : "🙈"}
          </StyledTimerToggle>
        </StyledTopBarMeta>
      </StyledTopBar>

      <StyledLayout>
        <StyledQuestionCard tone="surface">
          <QuestionField
            question={question}
            answer={answers[question.id]}
            onChange={(patch) => setAnswer(question.id, patch)}
          />
        </StyledQuestionCard>

        <StyledSidebar tone="surface">
          <StyledSidebarHeader>
            <StyledSidebarLabel>Questões</StyledSidebarLabel>
            <StyledMarkCurrentButton
              type="button"
              $marked={isMarked}
              onClick={() => toggleMarkedForReview(question.id)}
              aria-label={isMarked ? "Remover marcação para revisão" : "Marcar para revisão"}
              title={isMarked ? "Remover marcação para revisão" : "Marcar para revisão"}
            >
              🚩
            </StyledMarkCurrentButton>
          </StyledSidebarHeader>
          <StyledQuestionGrid>
            {quiz.questions.map((q, index) => {
              const answered = isQuestionAnswered(q, answers[q.id]);
              return (
                <StyledQuestionTile
                  key={q.id}
                  type="button"
                  $answered={answered}
                  $marked={markedForReview.has(q.id)}
                  $current={index === currentIndex}
                  onClick={() => setCurrentIndex(index)}
                >
                  {index + 1}
                </StyledQuestionTile>
              );
            })}
          </StyledQuestionGrid>
          <StyledLegend>
            <StyledLegendItem>
              <StyledLegendDot $tone="answered" />
              Respondida
            </StyledLegendItem>
            <StyledLegendItem>
              <StyledLegendDot $tone="current" />
              Atual
            </StyledLegendItem>
            <StyledLegendItem>
              <StyledLegendDot $tone="marked" />
              Marcada p/ revisão
            </StyledLegendItem>
            <StyledLegendItem>
              <StyledLegendDot $tone="empty" />
              Não respondida
            </StyledLegendItem>
          </StyledLegend>
        </StyledSidebar>
      </StyledLayout>

      <StyledFooter>
        <Button variant="secondary" onClick={goBack} disabled={currentIndex === 0}>
          Voltar
        </Button>
        <Button variant="primary" onClick={goNext}>
          {isLast ? "Ir para revisão" : "Avançar"}
        </Button>
      </StyledFooter>
    </StyledContent>
  );
}
