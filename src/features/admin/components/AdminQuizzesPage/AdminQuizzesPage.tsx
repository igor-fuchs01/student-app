import { useNavigate } from "react-router-dom";
import { useMutation, useQuery, useQueryClient } from "@tanstack/react-query";
import { Badge } from "@components/ui/Badge";
import { Button } from "@components/ui/Button";
import { StatusMessage } from "@components/ui/StatusMessage";
import { AdminLayout } from "@features/admin/components/AdminLayout";
import { ErrorNotice } from "@features/admin/components/ErrorNotice";
import { TextButton } from "@features/admin/components/TextButton";
import { DIFFICULTY_LABEL } from "@features/quizzes/difficultyLabel";
import { adminApi } from "@services/api/adminApi";
import { formatCount } from "@utils/formatCount";
import {
  StyledQuizCard,
  StyledQuizText,
  StyledQuizTitle,
  StyledMeta,
  StyledActions,
} from "./AdminQuizzesPage.styles";

export function AdminQuizzesPage() {
  const navigate = useNavigate();
  const queryClient = useQueryClient();

  const quizzesQuery = useQuery({
    queryKey: ["admin", "quizzes"],
    queryFn: ({ signal }) => adminApi.getQuizzes(signal),
  });

  const remove = useMutation({
    mutationFn: adminApi.deleteQuiz,
    onSuccess: () => queryClient.invalidateQueries({ queryKey: ["admin"] }),
  });

  const quizzes = quizzesQuery.data ?? [];

  return (
    <AdminLayout
      active="simulados"
      title="Simulados e listas de exercícios"
      subtitle="Um simulado é de uma disciplina e tem duração; uma lista de exercícios é de um assunto e não tem."
      actions={
        <>
          <Button variant="secondary" onClick={() => navigate("/admin/simulados/importar")}>
            Importar JSON
          </Button>
          <Button onClick={() => navigate("/admin/simulados/novo")}>Novo</Button>
        </>
      }
    >
      <ErrorNotice error={remove.error} />

      {quizzesQuery.isLoading && <StatusMessage message="Carregando simulados…" />}

      {quizzesQuery.isError && (
        <StatusMessage
          message="Não foi possível carregar os simulados agora."
          error={quizzesQuery.error}
          action={{ label: "Tentar novamente", onClick: () => quizzesQuery.refetch() }}
        />
      )}

      {quizzesQuery.data && quizzes.length === 0 && (
        <StatusMessage message="Nenhum simulado ou lista cadastrado." />
      )}

      {quizzes.map((quiz) => (
        <StyledQuizCard key={quiz.id}>
          <StyledQuizText>
            <StyledQuizTitle>{quiz.title}</StyledQuizTitle>
            <StyledMeta>
              <Badge tone={quiz.kind === "exam" ? "accent" : "accent2"}>
                {quiz.kind === "exam" ? "Simulado" : "Lista de exercícios"}
              </Badge>
              <span>
                {quiz.subjectName}
                {quiz.topicName && ` · ${quiz.topicName}`}
              </span>
              <span>· {formatCount(quiz.questionCount, "questão", "questões")}</span>
              {quiz.durationMinutes !== undefined && <span>· {quiz.durationMinutes} min</span>}
              <span>· {DIFFICULTY_LABEL[quiz.difficulty]}</span>
              <span>· {formatCount(quiz.attemptsCount, "tentativa", "tentativas")}</span>
            </StyledMeta>
          </StyledQuizText>
          <StyledActions>
            <TextButton onClick={() => navigate(`/admin/simulados/${quiz.id}`)}>Editar</TextButton>
            <TextButton
              tone="danger"
              disabled={remove.isPending}
              onClick={() => {
                if (window.confirm(`Excluir "${quiz.title}"? As questões continuam no banco.`)) {
                  remove.mutate(quiz.id);
                }
              }}
            >
              Excluir
            </TextButton>
          </StyledActions>
        </StyledQuizCard>
      ))}
    </AdminLayout>
  );
}
