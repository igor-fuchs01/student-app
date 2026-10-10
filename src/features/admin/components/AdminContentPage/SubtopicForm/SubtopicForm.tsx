import { useState } from "react";
import { useMutation, useQueryClient } from "@tanstack/react-query";
import { TextField } from "@components/ui/TextField";
import { AdminFormModal } from "@features/admin/components/AdminFormModal";
import { FieldGroup } from "@features/admin/components/FieldGroup";
import { TextAreaField } from "@features/admin/components/TextAreaField";
import { TextButton } from "@features/admin/components/TextButton";
import { removeAt, replaceAt } from "@features/admin/listEdits";
import { adminApi } from "@services/api/adminApi";
import type { AdminSubtopic, AdminSubtopicInput } from "@models/admin";
import { StyledItem } from "./SubtopicForm.styles";

type SubtopicFormProps = {
  topicId: string;
  subtopic?: AdminSubtopic;
  onClose: () => void;
};

type MaterialDraft = AdminSubtopicInput["materials"][number];

export function SubtopicForm({ topicId, subtopic, onClose }: SubtopicFormProps) {
  const queryClient = useQueryClient();
  const [name, setName] = useState(subtopic?.name ?? "");
  const [summary, setSummary] = useState(subtopic?.summary ?? "");
  const [keyPoints, setKeyPoints] = useState<string[]>(subtopic?.keyPoints ?? []);
  const [materials, setMaterials] = useState<MaterialDraft[]>(subtopic?.materials ?? []);

  const save = useMutation({
    mutationFn: adminApi.saveSubtopic,
    onSuccess: async () => {
      await queryClient.invalidateQueries({ queryKey: ["admin", "content"] });
      onClose();
    },
  });

  return (
    <AdminFormModal
      title={subtopic ? "Editar subassunto" : "Novo subassunto"}
      isSaving={save.isPending}
      error={save.error}
      onSubmit={() =>
        save.mutate({ id: subtopic?.id, topicId, name, summary, keyPoints, materials })
      }
      onClose={onClose}
    >
      <TextField
        label="Nome"
        value={name}
        maxLength={160}
        onChange={(event) => setName(event.target.value)}
        required
      />
      <TextAreaField
        label="Resumo"
        value={summary}
        maxLength={2000}
        onChange={(event) => setSummary(event.target.value)}
        required
      />

      <FieldGroup
        legend="Pontos-chave"
        addLabel="Adicionar ponto-chave"
        onAdd={() => setKeyPoints((current) => [...current, ""])}
      >
        {keyPoints.map((keyPoint, index) => (
          <StyledItem key={index}>
            <TextField
              label={`Ponto-chave ${index + 1}`}
              value={keyPoint}
              maxLength={500}
              onChange={(event) =>
                setKeyPoints((current) => replaceAt(current, index, event.target.value))
              }
              required
            />
            <TextButton
              tone="danger"
              onClick={() => setKeyPoints((current) => removeAt(current, index))}
            >
              Remover ponto-chave {index + 1}
            </TextButton>
          </StyledItem>
        ))}
      </FieldGroup>

      <FieldGroup
        legend="Materiais"
        addLabel="Adicionar material"
        onAdd={() => setMaterials((current) => [...current, { title: "", fileUrl: "" }])}
      >
        {materials.map((material, index) => (
          <StyledItem key={index}>
            <TextField
              label={`Título do material ${index + 1}`}
              value={material.title}
              maxLength={200}
              onChange={(event) =>
                setMaterials((current) =>
                  replaceAt(current, index, { ...material, title: event.target.value }),
                )
              }
              required
            />
            <TextField
              label="Endereço do PDF (https://)"
              type="url"
              placeholder="https://"
              value={material.fileUrl}
              maxLength={2000}
              onChange={(event) =>
                setMaterials((current) =>
                  replaceAt(current, index, { ...material, fileUrl: event.target.value }),
                )
              }
              required
            />
            <TextButton
              tone="danger"
              onClick={() => setMaterials((current) => removeAt(current, index))}
            >
              Remover material {index + 1}
            </TextButton>
          </StyledItem>
        ))}
      </FieldGroup>
    </AdminFormModal>
  );
}
