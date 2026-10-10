import { useState, type FormEvent } from "react";
import { useNavigate, useParams } from "react-router-dom";
import { useMutation, useQuery, useQueryClient } from "@tanstack/react-query";
import { Button } from "@components/ui/Button";
import { StatusMessage } from "@components/ui/StatusMessage";
import { TextField } from "@components/ui/TextField";
import { AdminLayout } from "@features/admin/components/AdminLayout";
import { ErrorNotice } from "@features/admin/components/ErrorNotice";
import { FieldGroup } from "@features/admin/components/FieldGroup";
import { SelectField } from "@features/admin/components/SelectField";
import { TextAreaField } from "@features/admin/components/TextAreaField";
import { TextButton } from "@features/admin/components/TextButton";
import { removeAt, replaceAt } from "@features/admin/listEdits";
import {
  EMPTY_QUESTION_DRAFT,
  emptyBlank,
  QUESTION_TYPE_LABEL,
  toQuestionDraft,
  toQuestionInput,
  type QuestionDraft,
} from "@features/admin/questionDraft";
import { adminApi } from "@services/api/adminApi";
import type { AdminQuestionType } from "@models/admin";
import { OptionsEditor } from "./OptionsEditor";
import {
  StyledFormCard,
  StyledColumns,
  StyledItem,
  StyledFooter,
} from "./AdminQuestionEditorPage.styles";

const TEMPLATE_HINT =
  "Marque cada lacuna com a chave entre chaves duplas, por exemplo: A capital do Brasil é {{b1}}.";

const TYPES_WITH_PROMPT: AdminQuestionType[] = [
  "multiple_choice",
  "multiple_answer",
  "essay",
  "essay_blanks",
];
const TYPES_WITH_TEMPLATE: AdminQuestionType[] = ["single_choice", "drag_and_drop", "essay_blanks"];
const TYPES_WITH_EXPLANATION: AdminQuestionType[] = [
  "multiple_choice",
  "multiple_answer",
  "single_choice",
  "drag_and_drop",
];

export function AdminQuestionEditorPage() {
  const { questionId } = useParams();
  const navigate = useNavigate();
  const queryClient = useQueryClient();
  const [editedDraft, setEditedDraft] = useState<QuestionDraft | null>(null);
  const [chosenSubjectId, setChosenSubjectId] = useState<string | null>(null);
  const [chosenTopicId, setChosenTopicId] = useState<string | null>(null);

  const contentQuery = useQuery({
    queryKey: ["admin", "content"],
    queryFn: ({ signal }) => adminApi.getContent(signal),
  });

  const questionQuery = useQuery({
    queryKey: ["admin", "question", questionId],
    queryFn: ({ signal }) => adminApi.getQuestion(questionId!, signal),
    enabled: questionId !== undefined,
  });

  const save = useMutation({
    mutationFn: adminApi.saveQuestion,
    onSuccess: async () => {
      await queryClient.invalidateQueries({ queryKey: ["admin"] });
      navigate("/admin/questoes");
    },
  });

  const question = questionQuery.data;
  const draft = editedDraft ?? (question ? toQuestionDraft(question) : EMPTY_QUESTION_DRAFT);
  const subjectId = chosenSubjectId ?? question?.subjectId ?? "";
  const topicId = chosenTopicId ?? question?.topicId ?? "";

  const subjects = contentQuery.data ?? [];
  const topics = subjects.find((subject) => subject.id === subjectId)?.topics ?? [];
  const terms = [...new Set(draft.terms.filter((term) => term.trim() !== ""))];

  function update(changes: Partial<QuestionDraft>) {
    setEditedDraft({ ...draft, ...changes });
  }

  function handleSubmit(event: FormEvent<HTMLFormElement>) {
    event.preventDefault();
    save.mutate({ id: questionId, topicId, ...toQuestionInput(draft) });
  }

  const isLoading = contentQuery.isLoading || questionQuery.isLoading;
  const loadError = contentQuery.error ?? questionQuery.error;

  return (
    <AdminLayout
      active="questoes"
      title={questionId ? "Editar questão" : "Nova questão"}
      subtitle={
        question?.answered
          ? "Esta questão já foi respondida por alunos: você pode corrigir os textos, mas não remover alternativas, lacunas ou termos que eles usaram nas respostas."
          : undefined
      }
    >
      {isLoading && <StatusMessage message="Carregando…" />}

      {loadError && (
        <StatusMessage message="Não foi possível carregar a questão agora." error={loadError} />
      )}

      {!isLoading && !loadError && (
        <StyledFormCard>
          <form onSubmit={handleSubmit}>
            <StyledColumns>
              <SelectField
                label="Disciplina"
                placeholder="Escolha a disciplina"
                options={subjects.map((subject) => ({ value: subject.id, label: subject.name }))}
                value={subjectId}
                onChange={(value) => {
                  setChosenSubjectId(value);
                  setChosenTopicId("");
                }}
                required
              />
              <SelectField
                label="Assunto"
                placeholder="Escolha o assunto"
                options={topics.map((topic) => ({
                  value: topic.id,
                  label: `Aula ${topic.number} — ${topic.name}`,
                }))}
                value={topicId}
                onChange={setChosenTopicId}
                disabled={!subjectId}
                required
              />
              <SelectField
                label="Tipo"
                options={Object.entries(QUESTION_TYPE_LABEL).map(([value, label]) => ({
                  value,
                  label,
                }))}
                value={draft.type}
                onChange={(value) => update({ type: value as AdminQuestionType })}
                disabled={questionId !== undefined}
              />
            </StyledColumns>

            {TYPES_WITH_PROMPT.includes(draft.type) && (
              <TextAreaField
                label="Enunciado"
                value={draft.prompt}
                maxLength={5000}
                onChange={(event) => update({ prompt: event.target.value })}
                required
              />
            )}

            {TYPES_WITH_TEMPLATE.includes(draft.type) && (
              <TextAreaField
                label="Texto com lacunas"
                hint={TEMPLATE_HINT}
                value={draft.template}
                maxLength={5000}
                onChange={(event) => update({ template: event.target.value })}
                required
              />
            )}

            {(draft.type === "multiple_choice" || draft.type === "multiple_answer") && (
              <OptionsEditor
                legend="Alternativas"
                options={draft.options}
                single={draft.type === "multiple_choice"}
                onChange={(options) => update({ options })}
              />
            )}

            {(draft.type === "single_choice" || draft.type === "essay_blanks") && (
              <FieldGroup
                legend="Lacunas"
                addLabel="Adicionar lacuna"
                onAdd={() =>
                  update({ blanks: [...draft.blanks, emptyBlank(`b${draft.blanks.length + 1}`)] })
                }
              >
                {draft.blanks.map((blank, index) => (
                  <StyledItem key={index}>
                    <TextField
                      label={`Chave da lacuna ${index + 1}`}
                      value={blank.key}
                      maxLength={32}
                      pattern="\w+"
                      title="Use só letras, números e sublinhado."
                      onChange={(event) =>
                        update({
                          blanks: replaceAt(draft.blanks, index, {
                            ...blank,
                            key: event.target.value,
                          }),
                        })
                      }
                      required
                    />
                    {draft.type === "single_choice" ? (
                      <OptionsEditor
                        legend={`Alternativas da lacuna ${index + 1}`}
                        options={blank.options}
                        single
                        onChange={(options) =>
                          update({ blanks: replaceAt(draft.blanks, index, { ...blank, options }) })
                        }
                      />
                    ) : (
                      <TextField
                        label="Resposta de referência"
                        value={blank.referenceAnswer}
                        maxLength={2000}
                        onChange={(event) =>
                          update({
                            blanks: replaceAt(draft.blanks, index, {
                              ...blank,
                              referenceAnswer: event.target.value,
                            }),
                          })
                        }
                        required
                      />
                    )}
                    <TextButton
                      tone="danger"
                      disabled={draft.blanks.length <= 1}
                      onClick={() => update({ blanks: removeAt(draft.blanks, index) })}
                    >
                      Remover lacuna {index + 1}
                    </TextButton>
                  </StyledItem>
                ))}
              </FieldGroup>
            )}

            {draft.type === "drag_and_drop" && (
              <>
                <FieldGroup
                  legend="Termos para arrastar"
                  hint="Inclua também os termos errados, que servem de distração."
                  addLabel="Adicionar termo"
                  onAdd={() => update({ terms: [...draft.terms, ""] })}
                >
                  {draft.terms.map((term, index) => (
                    <StyledItem key={index}>
                      <TextField
                        label={`Termo ${index + 1}`}
                        value={term}
                        maxLength={300}
                        onChange={(event) =>
                          update({ terms: replaceAt(draft.terms, index, event.target.value) })
                        }
                        required
                      />
                      <TextButton
                        tone="danger"
                        disabled={draft.terms.length <= 2}
                        onClick={() => update({ terms: removeAt(draft.terms, index) })}
                      >
                        Remover termo {index + 1}
                      </TextButton>
                    </StyledItem>
                  ))}
                </FieldGroup>

                <FieldGroup
                  legend="Lacunas"
                  addLabel="Adicionar lacuna"
                  onAdd={() =>
                    update({
                      slots: [
                        ...draft.slots,
                        { key: `s${draft.slots.length + 1}`, correctTerm: "" },
                      ],
                    })
                  }
                >
                  {draft.slots.map((slot, index) => (
                    <StyledItem key={index}>
                      <TextField
                        label={`Chave da lacuna ${index + 1}`}
                        value={slot.key}
                        maxLength={32}
                        pattern="\w+"
                        title="Use só letras, números e sublinhado."
                        onChange={(event) =>
                          update({
                            slots: replaceAt(draft.slots, index, {
                              ...slot,
                              key: event.target.value,
                            }),
                          })
                        }
                        required
                      />
                      <SelectField
                        label="Termo correto"
                        placeholder="Escolha o termo"
                        options={terms.map((term) => ({ value: term, label: term }))}
                        value={terms.includes(slot.correctTerm) ? slot.correctTerm : ""}
                        onChange={(correctTerm) =>
                          update({
                            slots: replaceAt(draft.slots, index, { ...slot, correctTerm }),
                          })
                        }
                        required
                      />
                      <TextButton
                        tone="danger"
                        disabled={draft.slots.length <= 1}
                        onClick={() => update({ slots: removeAt(draft.slots, index) })}
                      >
                        Remover lacuna {index + 1}
                      </TextButton>
                    </StyledItem>
                  ))}
                </FieldGroup>
              </>
            )}

            {draft.type === "essay" && (
              <>
                <TextField
                  label="Tamanho máximo da resposta (caracteres)"
                  type="number"
                  min={1}
                  max={20000}
                  step={1}
                  value={draft.maxLength}
                  onChange={(event) => update({ maxLength: event.target.value })}
                  required
                />
                <TextAreaField
                  label="Resposta de referência"
                  hint="O aluno compara a própria resposta com esta ao se autoavaliar."
                  value={draft.referenceAnswer}
                  maxLength={5000}
                  onChange={(event) => update({ referenceAnswer: event.target.value })}
                  required
                />
              </>
            )}

            {TYPES_WITH_EXPLANATION.includes(draft.type) && (
              <TextAreaField
                label="Explicação"
                hint="Mostrada ao aluno quando ele erra a questão."
                value={draft.explanation}
                maxLength={5000}
                onChange={(event) => update({ explanation: event.target.value })}
                required
              />
            )}

            <ErrorNotice error={save.error} />

            <StyledFooter>
              <Button
                type="button"
                variant="secondary"
                onClick={() => navigate("/admin/questoes")}
                disabled={save.isPending}
              >
                Cancelar
              </Button>
              <Button type="submit" isLoading={save.isPending}>
                Salvar questão
              </Button>
            </StyledFooter>
          </form>
        </StyledFormCard>
      )}
    </AdminLayout>
  );
}
