import { useState } from "react";
import { useNavigate, useParams } from "react-router-dom";
import { Badge } from "@components/ui/Badge";
import { Button } from "@components/ui/Button";
import { ProgressBar } from "@components/ui/ProgressBar";
import { AppHeader } from "@components/layout/AppHeader";
import { quizAttemptStorage } from "@services/storage/quizAttemptStorage";
import { toggleSetItem } from "@features/quizzes/toggleSetItem";
import { useLogout } from "@features/auth/hooks/useLogout";
import { ExamReview } from "./ExamReview";
import {
  StyledPage,
  StyledContent,
  StyledStateMessage,
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
  StyledReviewList,
  StyledReviewCard,
  StyledReviewSubject,
  StyledReviewExcerpt,
  StyledReviewToggle,
  StyledReviewExplanation,
  StyledMutedLabel,
  StyledAnswerComparison,
  StyledAnswerLabel,
  StyledAnswerText,
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
  const handleLogout = useLogout();
  const [attempt] = useState(() => quizAttemptStorage.load(quizId));
  const [revealed, setRevealed] = useState<Set<string>>(new Set());
  const [view, setView] = useState<ResultView>("performance");

  if (!attempt) {
    return (
      <StyledPage>
        <AppHeader active="simulados" onLogout={handleLogout} />
        <StyledContent>
          <StyledStateMessage>
            <p>Nenhum resultado deste simulado foi encontrado neste navegador.</p>
            <Button variant="secondary" onClick={() => navigate("/simulados")}>
              Ver simulados
            </Button>
          </StyledStateMessage>
        </StyledContent>
      </StyledPage>
    );
  }

  const { quiz, answers, result } = attempt;
  const gradedTotal = result.correctCount + result.incorrectCount + result.unansweredCount;

  function toggleReveal(questionId: string) {
    setRevealed((current) => toggleSetItem(current, questionId));
  }

  return (
    <StyledPage>
      <AppHeader active="simulados" onLogout={handleLogout} />
      <StyledContent>
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
          <ExamReview quiz={quiz} answers={answers} result={result} />
        ) : (
          <>
            <StyledBadgeRow>
              <Badge tone="accent">{result.correctCount} acertos</Badge>
              <Badge tone="danger">{result.incorrectCount} erros</Badge>
              <Badge tone="danger">{result.unansweredCount} não respondidas</Badge>
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
                {result.reviewItems.length === 0 ? (
                  <StyledMutedLabel>Nenhuma questão pendente de revisão. 🎉</StyledMutedLabel>
                ) : (
                  <StyledReviewList>
                    {result.reviewItems.map((item) => (
                      <StyledReviewCard key={item.questionId} tone="surface">
                        <StyledReviewSubject
                          $tone={item.status === "self_review" ? "accent2" : "danger"}
                        >
                          {item.subjectName}
                        </StyledReviewSubject>
                        <StyledReviewExcerpt>"{item.promptExcerpt}"</StyledReviewExcerpt>
                        {item.status === "self_review" ? (
                          <StyledAnswerComparison>
                            <div>
                              <StyledAnswerLabel>Sua resposta</StyledAnswerLabel>
                              <StyledAnswerText>{item.studentAnswer}</StyledAnswerText>
                            </div>
                            <div>
                              <StyledAnswerLabel>Resposta esperada</StyledAnswerLabel>
                              <StyledAnswerText>{item.referenceAnswer}</StyledAnswerText>
                            </div>
                            <StyledMutedLabel>
                              Compare as duas respostas e avalie se a sua está de acordo.
                            </StyledMutedLabel>
                          </StyledAnswerComparison>
                        ) : (
                          <>
                            <StyledReviewToggle onClick={() => toggleReveal(item.questionId)}>
                              {revealed.has(item.questionId)
                                ? "Ocultar gabarito comentado"
                                : "Ver gabarito comentado →"}
                            </StyledReviewToggle>
                            {revealed.has(item.questionId) && item.explanation && (
                              <StyledReviewExplanation>{item.explanation}</StyledReviewExplanation>
                            )}
                          </>
                        )}
                      </StyledReviewCard>
                    ))}
                  </StyledReviewList>
                )}
              </div>
            </StyledColumns>
          </>
        )}

        <StyledPageActions>
          <Button variant="secondary" onClick={() => navigate("/simulados")}>
            Voltar
          </Button>
          <Button
            variant="primary"
            onClick={() => setView(view === "performance" ? "review" : "performance")}
          >
            {view === "performance" ? "Rever prova" : "Mostrar desempenho"}
          </Button>
        </StyledPageActions>
      </StyledContent>
    </StyledPage>
  );
}
