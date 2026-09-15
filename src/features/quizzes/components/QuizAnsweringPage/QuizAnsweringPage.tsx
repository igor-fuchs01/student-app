import { Navigate, useNavigate } from "react-router-dom";
import { Button } from "@components/ui/Button";
import { QuestionField } from "@features/quizzes/components/QuestionField";
import {
  QuestionGrid,
  type QuestionGridLegendItem,
} from "@features/quizzes/components/QuestionGrid";
import { useQuizAttemptContext } from "@features/quizzes/hooks/useQuizAttemptContext";
import { isQuestionAnswered } from "@features/quizzes/isQuestionAnswered";
import {
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
  StyledFooter,
} from "./QuizAnsweringPage.styles";

const LEGEND: QuestionGridLegendItem[] = [
  { label: "Respondida", tone: "answered" },
  { label: "Atual", current: true },
  { label: "Marcada p/ revisão", tone: "empty", marked: true },
  { label: "Não respondida", tone: "empty" },
];

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
    isTimeUp,
  } = useQuizAttemptContext();

  if (isTimeUp) {
    return <Navigate to={`/simulados/${quiz.id}/revisao`} replace />;
  }

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
    <>
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
            key={question.id}
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
          <QuestionGrid
            tiles={quiz.questions.map((q, index) => ({
              id: q.id,
              tone: isQuestionAnswered(q, answers[q.id]) ? "answered" : "empty",
              marked: markedForReview.has(q.id),
              current: index === currentIndex,
            }))}
            legend={LEGEND}
            onSelect={setCurrentIndex}
          />
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
    </>
  );
}
