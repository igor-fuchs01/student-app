import { useState } from "react";
import { useMutation, useQuery, useQueryClient } from "@tanstack/react-query";
import { Button } from "@components/ui/Button";
import { StatusMessage } from "@components/ui/StatusMessage";
import { AdminLayout } from "@features/admin/components/AdminLayout";
import { ErrorNotice } from "@features/admin/components/ErrorNotice";
import { TextButton } from "@features/admin/components/TextButton";
import { adminApi } from "@services/api/adminApi";
import type { AdminSubject, AdminSubtopic, AdminTopic } from "@models/admin";
import { formatCount } from "@utils/formatCount";
import { SubjectForm } from "./SubjectForm";
import { SubtopicForm } from "./SubtopicForm";
import { TopicForm } from "./TopicForm";
import {
  StyledSubjectCard,
  StyledRow,
  StyledSubjectName,
  StyledTopic,
  StyledTopicName,
  StyledDescription,
  StyledSubtopics,
  StyledSubtopicName,
  StyledActions,
} from "./AdminContentPage.styles";

type OpenForm =
  | { kind: "subject"; subject?: AdminSubject }
  | { kind: "topic"; subject: AdminSubject; topic?: AdminTopic }
  | { kind: "subtopic"; topicId: string; subtopic?: AdminSubtopic };

type Removal = { kind: "subject" | "topic" | "subtopic"; id: string; confirmation: string };

const REMOVE: Record<Removal["kind"], (id: string) => Promise<unknown>> = {
  subject: adminApi.deleteSubject,
  topic: adminApi.deleteTopic,
  subtopic: adminApi.deleteSubtopic,
};

export function AdminContentPage() {
  const queryClient = useQueryClient();
  const [openForm, setOpenForm] = useState<OpenForm | null>(null);

  const contentQuery = useQuery({
    queryKey: ["admin", "content"],
    queryFn: ({ signal }) => adminApi.getContent(signal),
  });

  const remove = useMutation({
    mutationFn: ({ kind, id }: Removal) => REMOVE[kind](id),
    onSuccess: () => queryClient.invalidateQueries({ queryKey: ["admin", "content"] }),
  });

  function confirmRemoval(removal: Removal) {
    if (window.confirm(removal.confirmation)) remove.mutate(removal);
  }

  const subjects = contentQuery.data ?? [];

  return (
    <AdminLayout
      active="conteudo"
      title="Conteúdo"
      subtitle="Disciplinas, assuntos (aulas) e subassuntos que os alunos estudam."
      actions={<Button onClick={() => setOpenForm({ kind: "subject" })}>Nova disciplina</Button>}
    >
      {contentQuery.isLoading && <StatusMessage message="Carregando conteúdo…" />}

      {contentQuery.isError && (
        <StatusMessage
          message="Não foi possível carregar o conteúdo agora."
          error={contentQuery.error}
          action={{ label: "Tentar novamente", onClick: () => contentQuery.refetch() }}
        />
      )}

      <ErrorNotice error={remove.error} />

      {contentQuery.data && subjects.length === 0 && (
        <StatusMessage message="Nenhuma disciplina cadastrada." />
      )}

      {subjects.map((subject) => (
        <StyledSubjectCard key={subject.id}>
          <StyledRow>
            <StyledSubjectName>
              {subject.name}
              <span>{subject.shortLabel}</span>
            </StyledSubjectName>
            <StyledActions>
              <TextButton onClick={() => setOpenForm({ kind: "topic", subject })}>
                + Assunto
              </TextButton>
              <TextButton onClick={() => setOpenForm({ kind: "subject", subject })}>
                Editar
              </TextButton>
              <TextButton
                tone="danger"
                disabled={remove.isPending}
                onClick={() =>
                  confirmRemoval({
                    kind: "subject",
                    id: subject.id,
                    confirmation: `Excluir a disciplina "${subject.name}" com todos os assuntos, subassuntos e materiais?`,
                  })
                }
              >
                Excluir
              </TextButton>
            </StyledActions>
          </StyledRow>

          {subject.topics.map((topic) => (
            <StyledTopic key={topic.id}>
              <StyledRow>
                <div>
                  <StyledTopicName>
                    Aula {topic.number} — {topic.name}
                  </StyledTopicName>
                  <StyledDescription>{topic.description}</StyledDescription>
                </div>
                <StyledActions>
                  <TextButton onClick={() => setOpenForm({ kind: "subtopic", topicId: topic.id })}>
                    + Subassunto
                  </TextButton>
                  <TextButton onClick={() => setOpenForm({ kind: "topic", subject, topic })}>
                    Editar
                  </TextButton>
                  <TextButton
                    tone="danger"
                    disabled={remove.isPending}
                    onClick={() =>
                      confirmRemoval({
                        kind: "topic",
                        id: topic.id,
                        confirmation: `Excluir o assunto "${topic.name}" com os subassuntos e materiais?`,
                      })
                    }
                  >
                    Excluir
                  </TextButton>
                </StyledActions>
              </StyledRow>

              {topic.subtopics.length > 0 && (
                <StyledSubtopics>
                  {topic.subtopics.map((subtopic) => (
                    <li key={subtopic.id}>
                      <StyledRow>
                        <StyledSubtopicName>
                          {subtopic.name}
                          <small>
                            {formatCount(subtopic.keyPoints.length, "ponto-chave", "pontos-chave")}
                            {" · "}
                            {formatCount(subtopic.materials.length, "material", "materiais")}
                          </small>
                        </StyledSubtopicName>
                        <StyledActions>
                          <TextButton
                            onClick={() =>
                              setOpenForm({ kind: "subtopic", topicId: topic.id, subtopic })
                            }
                          >
                            Editar
                          </TextButton>
                          <TextButton
                            tone="danger"
                            disabled={remove.isPending}
                            onClick={() =>
                              confirmRemoval({
                                kind: "subtopic",
                                id: subtopic.id,
                                confirmation: `Excluir o subassunto "${subtopic.name}" com os materiais?`,
                              })
                            }
                          >
                            Excluir
                          </TextButton>
                        </StyledActions>
                      </StyledRow>
                    </li>
                  ))}
                </StyledSubtopics>
              )}
            </StyledTopic>
          ))}
        </StyledSubjectCard>
      ))}

      {openForm?.kind === "subject" && (
        <SubjectForm subject={openForm.subject} onClose={() => setOpenForm(null)} />
      )}
      {openForm?.kind === "topic" && (
        <TopicForm
          subjectId={openForm.subject.id}
          topic={openForm.topic}
          suggestedNumber={Math.max(0, ...openForm.subject.topics.map((topic) => topic.number)) + 1}
          onClose={() => setOpenForm(null)}
        />
      )}
      {openForm?.kind === "subtopic" && (
        <SubtopicForm
          topicId={openForm.topicId}
          subtopic={openForm.subtopic}
          onClose={() => setOpenForm(null)}
        />
      )}
    </AdminLayout>
  );
}
