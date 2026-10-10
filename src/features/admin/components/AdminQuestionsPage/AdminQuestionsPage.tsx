import { useState } from "react";
import { useNavigate } from "react-router-dom";
import { useMutation, useQuery, useQueryClient } from "@tanstack/react-query";
import { Button } from "@components/ui/Button";
import { FilterBar } from "@components/ui/FilterBar";
import { StatusMessage } from "@components/ui/StatusMessage";
import { AdminLayout } from "@features/admin/components/AdminLayout";
import { ErrorNotice } from "@features/admin/components/ErrorNotice";
import { QuestionSummaryRow } from "@features/admin/components/QuestionSummaryRow";
import { TextButton } from "@features/admin/components/TextButton";
import { adminApi } from "@services/api/adminApi";

export function AdminQuestionsPage() {
  const navigate = useNavigate();
  const queryClient = useQueryClient();
  const [subjectId, setSubjectId] = useState<string>();
  const [topicId, setTopicId] = useState<string>();

  const contentQuery = useQuery({
    queryKey: ["admin", "content"],
    queryFn: ({ signal }) => adminApi.getContent(signal),
  });

  const questionsQuery = useQuery({
    queryKey: ["admin", "questions", { subjectId, topicId }],
    queryFn: ({ signal }) => adminApi.getQuestions({ subjectId, topicId }, signal),
  });

  const remove = useMutation({
    mutationFn: adminApi.deleteQuestion,
    onSuccess: () => queryClient.invalidateQueries({ queryKey: ["admin", "questions"] }),
  });

  const subjects = contentQuery.data ?? [];
  const topics = subjects.find((subject) => subject.id === subjectId)?.topics ?? [];
  const questions = questionsQuery.data ?? [];

  return (
    <AdminLayout
      active="questoes"
      title="Questões"
      subtitle="O banco de questões. Uma questão entra em simulados e listas pela tela de simulados."
      actions={<Button onClick={() => navigate("/admin/questoes/nova")}>Nova questão</Button>}
    >
      <FilterBar
        label="Filtros das questões"
        filters={[
          {
            label: "Disciplina",
            allLabel: "Todas as disciplinas",
            options: subjects.map((subject) => ({ value: subject.id, label: subject.name })),
            value: subjectId,
            onChange: (value) => {
              setSubjectId(value);
              setTopicId(undefined);
            },
          },
          {
            label: "Assunto",
            allLabel: "Todos os assuntos",
            options: topics.map((topic) => ({
              value: topic.id,
              label: `Aula ${topic.number} — ${topic.name}`,
            })),
            value: topicId,
            disabled: !subjectId,
            onChange: setTopicId,
          },
        ]}
      />

      <ErrorNotice error={remove.error} />

      {questionsQuery.isLoading && <StatusMessage message="Carregando questões…" />}

      {questionsQuery.isError && (
        <StatusMessage
          message="Não foi possível carregar as questões agora."
          error={questionsQuery.error}
          action={{ label: "Tentar novamente", onClick: () => questionsQuery.refetch() }}
        />
      )}

      {questionsQuery.data && questions.length === 0 && (
        <StatusMessage message="Nenhuma questão encontrada." />
      )}

      {questions.map((question) => (
        <QuestionSummaryRow
          key={question.id}
          question={question}
          actions={
            <>
              <TextButton onClick={() => navigate(`/admin/questoes/${question.id}`)}>
                Editar
              </TextButton>
              <TextButton
                tone="danger"
                disabled={remove.isPending}
                onClick={() => {
                  if (window.confirm("Excluir esta questão?")) remove.mutate(question.id);
                }}
              >
                Excluir
              </TextButton>
            </>
          }
        />
      ))}
    </AdminLayout>
  );
}
