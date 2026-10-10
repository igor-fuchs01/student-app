import { useState, type FormEvent } from "react";
import { useNavigate, useParams } from "react-router-dom";
import { useMutation, useQuery, useQueryClient } from "@tanstack/react-query";
import { Button } from "@components/ui/Button";
import { StatusMessage } from "@components/ui/StatusMessage";
import { TextField } from "@components/ui/TextField";
import { AdminLayout } from "@features/admin/components/AdminLayout";
import { ErrorNotice } from "@features/admin/components/ErrorNotice";
import { QuestionSummaryRow } from "@features/admin/components/QuestionSummaryRow";
import { SelectField } from "@features/admin/components/SelectField";
import { TextButton } from "@features/admin/components/TextButton";
import { moveItem, removeAt } from "@features/admin/listEdits";
import { DIFFICULTY_LABEL } from "@features/quizzes/difficultyLabel";
import { adminApi } from "@services/api/adminApi";
import type { AdminQuestionSummary, AdminQuizDetail, AdminQuizKind } from "@models/admin";
import { formatCount } from "@utils/formatCount";
import {
  StyledFormCard,
  StyledFields,
  StyledColumns,
  StyledSectionTitle,
  StyledSectionHint,
  StyledFooter,
} from "./AdminQuizEditorPage.styles";

type QuizDraft = {
  title: string;
  kind: AdminQuizKind;
  subjectId: string;
  topicId: string;
  durationMinutes: string;
  difficulty: AdminQuizDetail["difficulty"];
  questions: AdminQuestionSummary[];
};

const EMPTY_QUIZ_DRAFT: QuizDraft = {
  title: "",
  kind: "exam",
  subjectId: "",
  topicId: "",
  durationMinutes: "30",
  difficulty: "medium",
  questions: [],
};

const KIND_OPTIONS: { value: AdminQuizKind; label: string }[] = [
  { value: "exam", label: "Simulado" },
  { value: "exercise", label: "Lista de exercícios" },
];

function toQuizDraft(quiz: AdminQuizDetail): QuizDraft {
  return {
    title: quiz.title,
    kind: quiz.kind,
    subjectId: quiz.subjectId,
    topicId: quiz.topicId ?? "",
    durationMinutes: String(quiz.durationMinutes ?? EMPTY_QUIZ_DRAFT.durationMinutes),
    difficulty: quiz.difficulty,
    questions: quiz.questions,
  };
}

export function AdminQuizEditorPage() {
  const { quizId } = useParams();
  const navigate = useNavigate();
  const queryClient = useQueryClient();
  const [editedDraft, setEditedDraft] = useState<QuizDraft | null>(null);
  const [bankTopicId, setBankTopicId] = useState("");

  const contentQuery = useQuery({
    queryKey: ["admin", "content"],
    queryFn: ({ signal }) => adminApi.getContent(signal),
  });

  const quizQuery = useQuery({
    queryKey: ["admin", "quiz", quizId],
    queryFn: ({ signal }) => adminApi.getQuiz(quizId!, signal),
    enabled: quizId !== undefined,
  });

  const draft = editedDraft ?? (quizQuery.data ? toQuizDraft(quizQuery.data) : EMPTY_QUIZ_DRAFT);
  const isExercise = draft.kind === "exercise";
  // An exercise list only takes questions of its assunto; a simulado, of any assunto of its subject.
  const bankFilters = {
    subjectId: draft.subjectId,
    topicId: (isExercise ? draft.topicId : bankTopicId) || undefined,
  };

  const bankEnabled = draft.subjectId !== "" && (!isExercise || draft.topicId !== "");

  const bankQuery = useQuery({
    queryKey: ["admin", "questions", bankFilters],
    queryFn: ({ signal }) => adminApi.getQuestions(bankFilters, signal),
    enabled: bankEnabled,
  });

  const save = useMutation({
    mutationFn: adminApi.saveQuiz,
    onSuccess: async () => {
      await queryClient.invalidateQueries({ queryKey: ["admin"] });
      navigate("/admin/simulados");
    },
  });

  const subjects = contentQuery.data ?? [];
  const topics = subjects.find((subject) => subject.id === draft.subjectId)?.topics ?? [];
  const topicOptions = topics.map((topic) => ({
    value: topic.id,
    label: `Aula ${topic.number} — ${topic.name}`,
  }));
  const availableQuestions = (bankQuery.data ?? []).filter(
    (candidate) => !draft.questions.some((question) => question.id === candidate.id),
  );

  function update(changes: Partial<QuizDraft>) {
    setEditedDraft({ ...draft, ...changes });
  }

  function handleSubmit(event: FormEvent<HTMLFormElement>) {
    event.preventDefault();
    save.mutate({
      id: quizId,
      title: draft.title,
      kind: draft.kind,
      subjectId: draft.subjectId,
      topicId: isExercise ? draft.topicId : undefined,
      durationMinutes: isExercise ? undefined : Number(draft.durationMinutes),
      difficulty: draft.difficulty,
      questionIds: draft.questions.map((question) => question.id),
    });
  }

  const isLoading = contentQuery.isLoading || quizQuery.isLoading;
  const loadError = contentQuery.error ?? quizQuery.error;

  return (
    <AdminLayout
      active="simulados"
      title={quizId ? "Editar simulado ou lista" : "Novo simulado ou lista"}
      subtitle="Defina os dados e escolha, no banco de questões, as que fazem parte dele."
    >
      {isLoading && <StatusMessage message="Carregando…" />}

      {loadError && (
        <StatusMessage message="Não foi possível carregar o simulado agora." error={loadError} />
      )}

      {!isLoading && !loadError && (
        <form onSubmit={handleSubmit}>
          <StyledFormCard>
            <TextField
              label="Título"
              value={draft.title}
              maxLength={200}
              onChange={(event) => update({ title: event.target.value })}
              required
            />
            <StyledFields>
              <SelectField
                label="Tipo"
                options={KIND_OPTIONS}
                value={draft.kind}
                onChange={(value) => {
                  const kind = value as AdminQuizKind;
                  update({
                    kind,
                    questions:
                      kind === "exercise"
                        ? draft.questions.filter((question) => question.topicId === draft.topicId)
                        : draft.questions,
                  });
                }}
              />
              <SelectField
                label="Disciplina"
                placeholder="Escolha a disciplina"
                options={subjects.map((subject) => ({ value: subject.id, label: subject.name }))}
                value={draft.subjectId}
                onChange={(subjectId) => {
                  update({ subjectId, topicId: "", questions: [] });
                  setBankTopicId("");
                }}
                required
              />
              {isExercise ? (
                <SelectField
                  label="Assunto"
                  placeholder="Escolha o assunto"
                  options={topicOptions}
                  value={draft.topicId}
                  onChange={(topicId) =>
                    update({
                      topicId,
                      questions: draft.questions.filter((question) => question.topicId === topicId),
                    })
                  }
                  disabled={!draft.subjectId}
                  required
                />
              ) : (
                <TextField
                  label="Duração (minutos)"
                  type="number"
                  min={1}
                  max={600}
                  step={1}
                  value={draft.durationMinutes}
                  onChange={(event) => update({ durationMinutes: event.target.value })}
                  required
                />
              )}
              <SelectField
                label="Dificuldade"
                options={Object.entries(DIFFICULTY_LABEL).map(([value, label]) => ({
                  value,
                  label,
                }))}
                value={draft.difficulty}
                onChange={(value) => update({ difficulty: value as QuizDraft["difficulty"] })}
              />
            </StyledFields>
          </StyledFormCard>

          <StyledColumns>
            <section>
              <StyledSectionTitle>
                Questões escolhidas ({formatCount(draft.questions.length, "questão", "questões")})
              </StyledSectionTitle>
              <StyledSectionHint>Na ordem em que o aluno responde.</StyledSectionHint>

              {draft.questions.length === 0 && (
                <StatusMessage message="Nenhuma questão escolhida ainda." />
              )}

              {draft.questions.map((question, index) => (
                <QuestionSummaryRow
                  key={question.id}
                  question={question}
                  position={index + 1}
                  actions={
                    <>
                      <TextButton
                        disabled={index === 0}
                        aria-label={`Mover a questão ${index + 1} para cima`}
                        onClick={() => update({ questions: moveItem(draft.questions, index, -1) })}
                      >
                        ↑
                      </TextButton>
                      <TextButton
                        disabled={index === draft.questions.length - 1}
                        aria-label={`Mover a questão ${index + 1} para baixo`}
                        onClick={() => update({ questions: moveItem(draft.questions, index, 1) })}
                      >
                        ↓
                      </TextButton>
                      <TextButton
                        tone="danger"
                        onClick={() => update({ questions: removeAt(draft.questions, index) })}
                      >
                        Remover
                      </TextButton>
                    </>
                  }
                />
              ))}
            </section>

            <section>
              <StyledSectionTitle>Banco de questões</StyledSectionTitle>
              <StyledSectionHint>
                {isExercise
                  ? "Questões do assunto da lista."
                  : "Questões da disciplina do simulado."}
              </StyledSectionHint>

              {!isExercise && draft.subjectId !== "" && (
                <SelectField
                  label="Filtrar por assunto"
                  placeholder="Todos os assuntos"
                  options={topicOptions}
                  value={bankTopicId}
                  onChange={setBankTopicId}
                />
              )}

              {!bankEnabled && (
                <StatusMessage
                  message={
                    isExercise
                      ? "Escolha a disciplina e o assunto para ver as questões."
                      : "Escolha a disciplina para ver as questões."
                  }
                />
              )}

              {bankQuery.isLoading && <StatusMessage message="Carregando questões…" />}

              {bankQuery.isError && (
                <StatusMessage
                  message="Não foi possível carregar as questões agora."
                  error={bankQuery.error}
                  action={{ label: "Tentar novamente", onClick: () => bankQuery.refetch() }}
                />
              )}

              {bankQuery.data && availableQuestions.length === 0 && (
                <StatusMessage message="Nenhuma questão disponível para adicionar." />
              )}

              {availableQuestions.map((question) => (
                <QuestionSummaryRow
                  key={question.id}
                  question={question}
                  actions={
                    <TextButton
                      onClick={() => update({ questions: [...draft.questions, question] })}
                    >
                      Adicionar
                    </TextButton>
                  }
                />
              ))}
            </section>
          </StyledColumns>

          <ErrorNotice error={save.error} />

          <StyledFooter>
            <Button
              type="button"
              variant="secondary"
              onClick={() => navigate("/admin/simulados")}
              disabled={save.isPending}
            >
              Cancelar
            </Button>
            <Button type="submit" isLoading={save.isPending}>
              Salvar
            </Button>
          </StyledFooter>
        </form>
      )}
    </AdminLayout>
  );
}
