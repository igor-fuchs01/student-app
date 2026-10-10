import { useState, type FormEvent } from "react";
import { useNavigate } from "react-router-dom";
import { useMutation, useQueryClient } from "@tanstack/react-query";
import { z } from "zod";
import { Button } from "@components/ui/Button";
import { AdminLayout } from "@features/admin/components/AdminLayout";
import { ErrorNotice } from "@features/admin/components/ErrorNotice";
import { TextAreaField } from "@features/admin/components/TextAreaField";
import { adminApi } from "@services/api/adminApi";
import { StyledFormCard, StyledFooter } from "./AdminQuizImportPage.styles";

const documentSchema = z.record(z.string(), z.unknown());

const EXAMPLE = `{
  "title": "Banco de Dados — Simulado 2",
  "subject": "Banco de Dados",
  "durationMinutes": 20,
  "difficulty": "medium",
  "questions": [
    {
      "type": "multiple_choice",
      "topic": "Modelagem ER",
      "prompt": "O que a cardinalidade de um relacionamento indica?",
      "explanation": "Quantas ocorrências de uma entidade se ligam a ocorrências da outra.",
      "options": [
        { "text": "Quantas ocorrências se relacionam", "isCorrect": true },
        { "text": "Quantos atributos a entidade possui", "isCorrect": false }
      ]
    }
  ]
}`;

function parseDocument(text: string): Record<string, unknown> {
  let parsed: unknown;
  try {
    parsed = JSON.parse(text);
  } catch {
    throw new Error("O texto não é um JSON válido. Confira vírgulas, aspas e chaves.");
  }

  const document = documentSchema.safeParse(parsed);
  if (!document.success) throw new Error("O JSON precisa ser um objeto descrevendo um simulado.");
  return document.data;
}

export function AdminQuizImportPage() {
  const navigate = useNavigate();
  const queryClient = useQueryClient();
  const [text, setText] = useState("");

  const importQuiz = useMutation({
    mutationFn: async (source: string) => adminApi.importQuiz(parseDocument(source)),
    onSuccess: async ({ id }) => {
      await queryClient.invalidateQueries({ queryKey: ["admin"] });
      navigate(`/admin/simulados/${id}`);
    },
  });

  function handleSubmit(event: FormEvent<HTMLFormElement>) {
    event.preventDefault();
    importQuiz.mutate(text);
  }

  return (
    <AdminLayout
      active="simulados"
      title="Importar simulado ou lista"
      subtitle="Cole o JSON de um simulado. As questões dele são criadas como questões novas; a disciplina e os assuntos precisam já existir, com o mesmo nome."
    >
      <StyledFormCard>
        <form onSubmit={handleSubmit}>
          <TextAreaField
            label="JSON do simulado"
            hint='Para uma lista de exercícios, use "kind": "exercise" com "topic" e sem "durationMinutes".'
            placeholder={EXAMPLE}
            value={text}
            spellCheck={false}
            onChange={(event) => setText(event.target.value)}
            required
          />

          <ErrorNotice error={importQuiz.error} />

          <StyledFooter>
            <Button
              type="button"
              variant="secondary"
              onClick={() => navigate("/admin/simulados")}
              disabled={importQuiz.isPending}
            >
              Cancelar
            </Button>
            <Button type="submit" isLoading={importQuiz.isPending}>
              Importar
            </Button>
          </StyledFooter>
        </form>
      </StyledFormCard>
    </AdminLayout>
  );
}
