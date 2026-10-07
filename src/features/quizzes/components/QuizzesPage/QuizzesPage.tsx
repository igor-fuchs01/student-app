import { useState } from "react";
import { useNavigate } from "react-router-dom";
import { useQuery } from "@tanstack/react-query";
import { Button } from "@components/ui/Button";
import { FilterBar } from "@components/ui/FilterBar";
import { StatusMessage } from "@components/ui/StatusMessage";
import { PageLayout } from "@components/layout/PageLayout";
import { StartQuizModal } from "@features/quizzes/components/StartQuizModal";
import { DIFFICULTY_LABEL } from "@features/quizzes/difficultyLabel";
import { quizzesApi } from "@services/api/quizzesApi";
import type { QuizDifficulty, QuizSummary } from "@models/quizzes";
import { formatCount } from "@utils/formatCount";
import {
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

export function QuizzesPage() {
  const navigate = useNavigate();
  const [startModalQuiz, setStartModalQuiz] = useState<QuizSummary | null>(null);
  const [subjectFilter, setSubjectFilter] = useState<string>();
  const [difficultyFilter, setDifficultyFilter] = useState<QuizDifficulty>();

  const quizzesQuery = useQuery({
    queryKey: ["quizzes"],
    queryFn: ({ signal }) => quizzesApi.getQuizzes(signal),
  });

  const quizzes = quizzesQuery.data ?? [];
  const subjectNames = [...new Set(quizzes.map((quiz) => quiz.subjectName))];
  const visibleQuizzes = quizzes.filter(
    (quiz) =>
      (!subjectFilter || quiz.subjectName === subjectFilter) &&
      (!difficultyFilter || quiz.difficulty === difficultyFilter),
  );

  function confirmStart(timeLimitEnabled: boolean) {
    if (!startModalQuiz) return;
    navigate(`/simulados/${startModalQuiz.id}`, { state: { timeLimitEnabled } });
  }

  return (
    <PageLayout active="simulados">
      {quizzesQuery.isLoading && <StatusMessage message="Carregando simulados…" />}

      {quizzesQuery.isError && (
        <StatusMessage
          message="Não foi possível carregar os simulados agora."
          error={quizzesQuery.error}
          action={{ label: "Tentar novamente", onClick: () => quizzesQuery.refetch() }}
        />
      )}

      {quizzesQuery.data && (
        <>
          <StyledPageTitle>Lista de simulados</StyledPageTitle>
          <StyledPageSubtitle>Um simulado por disciplina, com as questões dela.</StyledPageSubtitle>

          {quizzes.length > 0 && (
            <FilterBar
              label="Filtros dos simulados"
              filters={[
                {
                  label: "Disciplina",
                  allLabel: "Todas as disciplinas",
                  options: subjectNames.map((name) => ({ value: name, label: name })),
                  value: subjectFilter,
                  onChange: setSubjectFilter,
                },
                {
                  label: "Dificuldade",
                  allLabel: "Todas as dificuldades",
                  options: Object.entries(DIFFICULTY_LABEL).map(([value, label]) => ({
                    value,
                    label,
                  })),
                  value: difficultyFilter,
                  onChange: (value) => setDifficultyFilter(value as QuizDifficulty | undefined),
                },
              ]}
            />
          )}

          {quizzes.length > 0 && visibleQuizzes.length === 0 && (
            <StatusMessage message="Nenhum simulado encontrado com esses filtros." />
          )}

          {visibleQuizzes.length > 0 && (
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
                  {visibleQuizzes.map((quiz) => (
                    <StyledTableRow key={quiz.id}>
                      <StyledQuizTitle>{quiz.title}</StyledQuizTitle>
                      <td>
                        <StyledSubjectBadge>{quiz.subjectName}</StyledSubjectBadge>
                      </td>
                      <td>{formatCount(quiz.questionCount, "questão", "questões")}</td>
                      <td>{quiz.durationMinutes} min</td>
                      <td>{formatCount(quiz.attemptsCount, "tentativa", "tentativas")}</td>
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
          )}
        </>
      )}

      {startModalQuiz && (
        <StartQuizModal
          quizTitle={startModalQuiz.title}
          questionCount={startModalQuiz.questionCount}
          durationMinutes={startModalQuiz.durationMinutes}
          onCancel={() => setStartModalQuiz(null)}
          onConfirm={confirmStart}
        />
      )}
    </PageLayout>
  );
}
