import { useState } from "react";
import { useNavigate, useParams } from "react-router-dom";
import { Badge } from "@components/ui/Badge";
import { Button } from "@components/ui/Button";
import { ProgressBar } from "@components/ui/ProgressBar";
import { StatusMessage } from "@components/ui/StatusMessage";
import { PageLayout } from "@components/layout/PageLayout";
import { useAuthStore } from "@features/auth/store/useAuthStore";
import { ExamReview } from "@features/quizzes/components/ExamReview";
import { QuestionGrid } from "@features/quizzes/components/QuestionGrid";
import { useAttemptKind } from "@features/quizzes/hooks/useAttemptKind";
import {
  QUESTION_STATUS_LEGEND,
  getQuestionReviewStatuses,
} from "@features/quizzes/questionReviewStatus";
import { quizAttemptStorage } from "@services/storage/quizAttemptStorage";
import { formatCount } from "@utils/formatCount";
import {
  StyledHeaderRow,
  StyledTitle,
  StyledSubmittedAt,
  StyledPageActions,
  StyledScoreBox,
  StyledScoreValue,
  StyledScoreLabel,
  StyledBadgeRow,
  StyledColumns,
  StyledColumnTitle,
  StyledPerformanceList,
  StyledPerformanceHeader,
} from "./QuizResultPage.styles";

type ResultView = "performance" | "review";

function formatSubmittedAt(iso: string): string {
  const date = new Date(iso);
  const datePart = date.toLocaleDateString("pt-BR");
  const timePart = date.toLocaleTimeString("pt-BR", { hour: "2-digit", minute: "2-digit" });
  return `Enviado em ${datePart}, às ${timePart}`;
}

export function QuizResultPage() {
  const { quizId = "" } = useParams<{ quizId: string }>();
  const navigate = useNavigate();
  const userId = useAuthStore((state) => state.user?.id);
  const attemptKind = useAttemptKind();
  const [attempt] = useState(() => (userId ? quizAttemptStorage.load(userId, quizId) : null));
  const [view, setView] = useState<ResultView>("performance");
  const [reviewStartIndex, setReviewStartIndex] = useState(0);

  if (!attempt) {
    return (
      <PageLayout active={attemptKind.navKey}>
        <StatusMessage
          message={attemptKind.resultNotFoundMessage}
          action={{
            label: attemptKind.seeListLabel,
            onClick: () => navigate(attemptKind.listPath),
          }}
        />
      </PageLayout>
    );
  }

  const { quiz, answers, result } = attempt;
  const gradedTotal = result.correctCount + result.incorrectCount + result.unansweredCount;

  const statuses = getQuestionReviewStatuses(quiz.questions, answers, result);

  function openReview(index: number) {
    setReviewStartIndex(index);
    setView("review");
  }

  return (
    <PageLayout active={attemptKind.navKey}>
      <StyledHeaderRow>
        <div>
          <StyledTitle>Resultado — {quiz.title}</StyledTitle>
          <StyledSubmittedAt>{formatSubmittedAt(result.submittedAt)}</StyledSubmittedAt>
        </div>
        {view === "performance" && (
          <StyledScoreBox>
            <StyledScoreValue>
              {result.correctCount}/{gradedTotal}
            </StyledScoreValue>
            <StyledScoreLabel>{result.scorePercent}% de aproveitamento</StyledScoreLabel>
          </StyledScoreBox>
        )}
      </StyledHeaderRow>

      {view === "review" ? (
        <ExamReview quiz={quiz} answers={answers} result={result} initialIndex={reviewStartIndex} />
      ) : (
        <>
          <StyledBadgeRow>
            <Badge tone="accent">{formatCount(result.correctCount, "acerto", "acertos")}</Badge>
            <Badge tone="danger">{formatCount(result.incorrectCount, "erro", "erros")}</Badge>
            <Badge tone="danger">
              {formatCount(result.unansweredCount, "não respondida", "não respondidas")}
            </Badge>
            {result.selfReviewCount > 0 && (
              <Badge tone="accent2">{result.selfReviewCount} para autoavaliar</Badge>
            )}
          </StyledBadgeRow>

          <StyledColumns>
            <div>
              <StyledColumnTitle>Desempenho por assunto</StyledColumnTitle>
              <StyledPerformanceList>
                {result.subjectPerformance.map((subject) => (
                  <div key={subject.subjectName}>
                    <StyledPerformanceHeader>
                      <span>{subject.subjectName}</span>
                      <span>{subject.percent}%</span>
                    </StyledPerformanceHeader>
                    <ProgressBar
                      value={subject.percent}
                      label={`Desempenho em ${subject.subjectName}`}
                    />
                  </div>
                ))}
              </StyledPerformanceList>
            </div>

            <div>
              <StyledColumnTitle>Questões para revisar</StyledColumnTitle>
              <QuestionGrid
                variant="wide"
                tiles={quiz.questions.map((question, index) => ({
                  id: question.id,
                  tone: statuses[index],
                }))}
                legend={QUESTION_STATUS_LEGEND}
                onSelect={openReview}
              />
            </div>
          </StyledColumns>
        </>
      )}

      <StyledPageActions>
        <Button variant="secondary" onClick={() => navigate(attemptKind.listPath)}>
          Voltar
        </Button>
        <Button
          variant="primary"
          onClick={() => (view === "performance" ? openReview(0) : setView("performance"))}
        >
          {view === "performance" ? attemptKind.reviewLabel : "Mostrar desempenho"}
        </Button>
      </StyledPageActions>
    </PageLayout>
  );
}
