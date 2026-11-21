import { Fragment, useState, type MouseEvent } from "react";
import { useNavigate } from "react-router-dom";
import { useQuery } from "@tanstack/react-query";
import { Button } from "@components/ui/Button";
import { FilterBar } from "@components/ui/FilterBar";
import { StatusMessage } from "@components/ui/StatusMessage";
import { PageLayout } from "@components/layout/PageLayout";
import { QuizContentSummary } from "@features/quizzes/components/QuizContentSummary";
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
  StyledQuizToggle,
  StyledSubjectBadge,
  StyledSummaryRow,
} from "./QuizzesPage.styles";

const SPRINT_OPTIONS = [1, 2, 3].map((sprint) => ({
  value: String(sprint),
  label: String(sprint),
}));
const SEMESTER_OPTIONS = [1, 2, 3, 4, 5].map((semester) => ({
  value: String(semester),
  label: `${semester}º`,
}));

// A simulado matches when every sprint it covers is checked, so "Sprint 1 e 2" shows up only with
// both checked. One without sprints shows up only while no sprint is checked.
function matchesSprints(sprints: number[], checked: string[]): boolean {
  if (checked.length === 0) return true;
  return sprints.length > 0 && sprints.every((sprint) => checked.includes(String(sprint)));
}

export function QuizzesPage() {
  const navigate = useNavigate();
  const [startModalQuiz, setStartModalQuiz] = useState<QuizSummary | null>(null);
  const [subjectFilter, setSubjectFilter] = useState<string>();
  const [difficultyFilter, setDifficultyFilter] = useState<QuizDifficulty>();
  const [sprintFilter, setSprintFilter] = useState<string[]>([]);
  const [semesterFilter, setSemesterFilter] = useState<string[]>([]);
  const [selectedQuizId, setSelectedQuizId] = useState<string | null>(null);

  const quizzesQuery = useQuery({
    queryKey: ["quizzes"],
    queryFn: ({ signal }) => quizzesApi.getQuizzes(signal),
  });

  const quizzes = quizzesQuery.data ?? [];
  const subjectNames = [...new Set(quizzes.map((quiz) => quiz.subjectName))];
  const visibleQuizzes = quizzes.filter(
    (quiz) =>
      (!subjectFilter || quiz.subjectName === subjectFilter) &&
      (!difficultyFilter || quiz.difficulty === difficultyFilter) &&
      (semesterFilter.length === 0 || semesterFilter.includes(String(quiz.semester))) &&
      matchesSprints(quiz.sprints, sprintFilter),
  );

  function toggleSelected(quizId: string) {
    setSelectedQuizId((current) => (current === quizId ? null : quizId));
  }

  // A click anywhere on the row selects it, except on its buttons, which handle their own click.
  function handleRowClick(event: MouseEvent<HTMLTableRowElement>, quizId: string) {
    if ((event.target as HTMLElement).closest("button")) return;
    toggleSelected(quizId);
  }

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
          <StyledPageSubtitle>
            Selecione um simulado para ver os assuntos que ele aborda antes de começar.
          </StyledPageSubtitle>

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
                {
                  type: "checkboxes",
                  label: "Sprint",
                  options: SPRINT_OPTIONS,
                  values: sprintFilter,
                  onChange: setSprintFilter,
                },
                {
                  type: "checkboxes",
                  label: "Semestre",
                  options: SEMESTER_OPTIONS,
                  values: semesterFilter,
                  onChange: setSemesterFilter,
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
                  {visibleQuizzes.map((quiz) => {
                    const selected = quiz.id === selectedQuizId;
                    const summaryId = `quiz-content-${quiz.id}`;
                    return (
                      <Fragment key={quiz.id}>
                        <StyledTableRow
                          $selected={selected}
                          onClick={(event) => handleRowClick(event, quiz.id)}
                        >
                          <StyledQuizTitle>
                            <StyledQuizToggle
                              type="button"
                              aria-expanded={selected}
                              aria-controls={selected ? summaryId : undefined}
                              onClick={() => toggleSelected(quiz.id)}
                            >
                              <span aria-hidden="true">{selected ? "▾" : "▸"}</span>
                              <span>{quiz.title}</span>
                            </StyledQuizToggle>
                          </StyledQuizTitle>
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
                        {selected && (
                          <StyledSummaryRow>
                            <td colSpan={7}>
                              <QuizContentSummary id={summaryId} topics={quiz.topics} />
                            </td>
                          </StyledSummaryRow>
                        )}
                      </Fragment>
                    );
                  })}
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
