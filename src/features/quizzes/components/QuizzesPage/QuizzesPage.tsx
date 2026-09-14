import { useState } from "react";
import { useNavigate } from "react-router-dom";
import { useQuery } from "@tanstack/react-query";
import { Button } from "@components/ui/Button";
import { AppHeader } from "@components/layout/AppHeader";
import { StartQuizModal } from "@features/quizzes/components/StartQuizModal";
import { quizzesApi } from "@services/api/quizzesApi";
import { useLogout } from "@features/auth/hooks/useLogout";
import type { QuizDifficulty, QuizSummary } from "@models/quizzes";
import {
  StyledPage,
  StyledContent,
  StyledStateMessage,
  StyledPageTitle,
  StyledPageSubtitle,
  StyledTableCard,
  StyledTable,
  StyledCol,
  StyledTableHead,
  StyledTableRow,
  StyledQuizTitle,
  StyledSubjectBadge,
} from "./QuizzesPage.styles";

const DIFFICULTY_LABEL: Record<QuizDifficulty, string> = {
  easy: "Fácil",
  medium: "Média",
  hard: "Difícil",
};

export function QuizzesPage() {
  const navigate = useNavigate();
  const handleLogout = useLogout();
  const [startModalQuiz, setStartModalQuiz] = useState<QuizSummary | null>(null);

  const quizzesQuery = useQuery({
    queryKey: ["quizzes"],
    queryFn: ({ signal }) => quizzesApi.getQuizzes(signal),
  });

  function confirmStart(timeLimitEnabled: boolean) {
    if (!startModalQuiz) return;
    navigate(`/simulados/${startModalQuiz.id}`, { state: { timeLimitEnabled } });
  }

  return (
    <StyledPage>
      <AppHeader active="simulados" onLogout={handleLogout} />

      <StyledContent>
        {quizzesQuery.isLoading && (
          <StyledStateMessage>Carregando simulados…</StyledStateMessage>
        )}

        {quizzesQuery.isError && (
          <StyledStateMessage>
            <p role="alert">
              Não foi possível carregar os simulados agora.{" "}
              {quizzesQuery.error instanceof Error
                ? quizzesQuery.error.message
                : ""}
            </p>
            <Button variant="secondary" onClick={() => quizzesQuery.refetch()}>
              Tentar novamente
            </Button>
          </StyledStateMessage>
        )}

        {quizzesQuery.data && (
          <>
            <StyledPageTitle>Lista de simulados</StyledPageTitle>
            <StyledPageSubtitle>
              Um simulado por disciplina e um integrado que mistura diversas questões.
            </StyledPageSubtitle>

            <StyledTableCard tone="surface">
              <StyledTable>
                <colgroup>
                  <StyledCol $width="26%" />
                  <StyledCol $width="18%" />
                  <StyledCol $width="10%" />
                  <StyledCol $width="10%" />
                  <StyledCol $width="12%" />
                  <StyledCol $width="12%" />
                  <StyledCol $width="12%" />
                </colgroup>
                <StyledTableHead>
                  <tr>
                    <th>Simulado</th>
                    <th>Disciplina</th>
                    <th>Questões</th>
                    <th>Duração</th>
                    <th>Tentativas</th>
                    <th>Dificuldade</th>
                    <th />
                  </tr>
                </StyledTableHead>
                <tbody>
                  {quizzesQuery.data.map((quiz) => (
                    <StyledTableRow key={quiz.id}>
                      <StyledQuizTitle>{quiz.title}</StyledQuizTitle>
                      <td>
                        <StyledSubjectBadge
                          $integrated={quiz.subjectScope === "all"}
                        >
                          {quiz.subjectScope === "all"
                            ? "Todas"
                            : quiz.subjectName}
                        </StyledSubjectBadge>
                      </td>
                      <td>{quiz.questionCount}</td>
                      <td>{quiz.durationMinutes} min</td>
                      <td>{quiz.attemptsRemaining} restantes</td>
                      <td>{DIFFICULTY_LABEL[quiz.difficulty]}</td>
                      <td>
                        <Button variant="secondary" onClick={() => setStartModalQuiz(quiz)}>
                          Iniciar
                        </Button>
                      </td>
                    </StyledTableRow>
                  ))}
                </tbody>
              </StyledTable>
            </StyledTableCard>
          </>
        )}
      </StyledContent>

      {startModalQuiz && (
        <StartQuizModal
          quizTitle={startModalQuiz.title}
          questionCount={startModalQuiz.questionCount}
          durationMinutes={startModalQuiz.durationMinutes}
          onCancel={() => setStartModalQuiz(null)}
          onConfirm={confirmStart}
        />
      )}
    </StyledPage>
  );
}
