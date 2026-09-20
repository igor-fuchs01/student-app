import { useMemo, useState } from "react";
import { useQuery } from "@tanstack/react-query";
import { Badge, type BadgeTone } from "@components/ui/Badge";
import { StatusMessage } from "@components/ui/StatusMessage";
import { quizzesApi } from "@services/api/quizzesApi";
import type { QuizDifficulty, QuizSummary } from "@models/quizzes";
import {
  StyledSectionHeader,
  StyledSectionTitle,
  StyledFilterGroup,
  StyledFilterChip,
  StyledQuizList,
  StyledQuizCard,
  StyledQuizCardTopRow,
  StyledQuizTitle,
  StyledQuizMeta,
  StyledEmptyMessage,
} from "./NewQuizzesSection.styles";

const DIFFICULTY_FILTERS: { value: QuizDifficulty | "all"; label: string }[] = [
  { value: "all", label: "Todas" },
  { value: "easy", label: "Fácil" },
  { value: "medium", label: "Média" },
  { value: "hard", label: "Difícil" },
];

const STATUS_FILTERS: { value: StatusFilter; label: string }[] = [
  { value: "all", label: "Todos" },
  { value: "to_do", label: "A fazer" },
  { value: "done", label: "Feitos" },
];

const DIFFICULTY_LABEL: Record<QuizDifficulty, string> = {
  easy: "Fácil",
  medium: "Média",
  hard: "Difícil",
};

const DIFFICULTY_TONE: Record<QuizDifficulty, BadgeTone> = {
  easy: "accent",
  medium: "neutral",
  hard: "accent2",
};

const RECENT_QUIZZES_LIMIT = 6;

type StatusFilter = "all" | "to_do" | "done";

function matchesStatus(quiz: QuizSummary, status: StatusFilter): boolean {
  if (status === "done") return quiz.attemptsCount > 0;
  if (status === "to_do") return quiz.attemptsCount === 0;
  return true;
}

export function NewQuizzesSection() {
  const [difficultyFilter, setDifficultyFilter] = useState<QuizDifficulty | "all">("all");
  const [statusFilter, setStatusFilter] = useState<StatusFilter>("all");

  const quizzesQuery = useQuery({
    queryKey: ["quizzes"],
    queryFn: ({ signal }) => quizzesApi.getQuizzes(signal),
  });

  const filteredQuizzes = useMemo(() => {
    const quizzes = quizzesQuery.data ?? [];
    return quizzes
      .filter((quiz) => difficultyFilter === "all" || quiz.difficulty === difficultyFilter)
      .filter((quiz) => matchesStatus(quiz, statusFilter))
      .slice(0, RECENT_QUIZZES_LIMIT);
  }, [quizzesQuery.data, difficultyFilter, statusFilter]);

  return (
    <section>
      <StyledSectionHeader>
        <StyledSectionTitle>Novos simulados e exercícios</StyledSectionTitle>

        <StyledFilterGroup>
          {DIFFICULTY_FILTERS.map((filter) => (
            <StyledFilterChip
              key={filter.value}
              type="button"
              $active={difficultyFilter === filter.value}
              onClick={() => setDifficultyFilter(filter.value)}
            >
              {filter.label}
            </StyledFilterChip>
          ))}
        </StyledFilterGroup>

        <StyledFilterGroup>
          {STATUS_FILTERS.map((filter) => (
            <StyledFilterChip
              key={filter.value}
              type="button"
              $active={statusFilter === filter.value}
              onClick={() => setStatusFilter(filter.value)}
            >
              {filter.label}
            </StyledFilterChip>
          ))}
        </StyledFilterGroup>
      </StyledSectionHeader>

      {quizzesQuery.isLoading && <StatusMessage message="Carregando simulados…" />}

      {quizzesQuery.isError && (
        <StatusMessage
          message="Não foi possível carregar os simulados agora."
          error={quizzesQuery.error}
          action={{ label: "Tentar novamente", onClick: () => quizzesQuery.refetch() }}
        />
      )}

      {quizzesQuery.data && filteredQuizzes.length === 0 && (
        <StyledEmptyMessage>Nenhum simulado encontrado para esse filtro.</StyledEmptyMessage>
      )}

      {quizzesQuery.data && filteredQuizzes.length > 0 && (
        <StyledQuizList>
          {filteredQuizzes.map((quiz) => (
            <StyledQuizCard key={quiz.id} tone="surface">
              <StyledQuizCardTopRow>
                <StyledQuizTitle>{quiz.title}</StyledQuizTitle>
                <Badge tone={DIFFICULTY_TONE[quiz.difficulty]}>
                  {DIFFICULTY_LABEL[quiz.difficulty]}
                </Badge>
              </StyledQuizCardTopRow>

              <StyledQuizMeta>
                {quiz.subjectScope === "all" ? "Simulado integrado" : quiz.subjectName} ·{" "}
                {quiz.questionCount} questões · {quiz.durationMinutes} min
              </StyledQuizMeta>

              <Badge tone={quiz.attemptsCount > 0 ? "accent" : "neutral"}>
                {quiz.attemptsCount > 0 ? "Feito" : "A fazer"}
              </Badge>
            </StyledQuizCard>
          ))}
        </StyledQuizList>
      )}
    </section>
  );
}