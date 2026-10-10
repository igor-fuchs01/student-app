import { useState } from "react";
import { useMutation, useQueryClient } from "@tanstack/react-query";
import { TextField } from "@components/ui/TextField";
import { AdminFormModal } from "@features/admin/components/AdminFormModal";
import { TextAreaField } from "@features/admin/components/TextAreaField";
import { adminApi } from "@services/api/adminApi";
import type { AdminTopic } from "@models/admin";

type TopicFormProps = {
  subjectId: string;
  topic?: AdminTopic;
  suggestedNumber: number;
  onClose: () => void;
};

export function TopicForm({ subjectId, topic, suggestedNumber, onClose }: TopicFormProps) {
  const queryClient = useQueryClient();
  const [number, setNumber] = useState(String(topic?.number ?? suggestedNumber));
  const [name, setName] = useState(topic?.name ?? "");
  const [description, setDescription] = useState(topic?.description ?? "");

  const save = useMutation({
    mutationFn: adminApi.saveTopic,
    onSuccess: async () => {
      await queryClient.invalidateQueries({ queryKey: ["admin", "content"] });
      onClose();
    },
  });

  return (
    <AdminFormModal
      title={topic ? "Editar assunto" : "Novo assunto"}
      isSaving={save.isPending}
      error={save.error}
      onSubmit={() =>
        save.mutate({ id: topic?.id, subjectId, number: Number(number), name, description })
      }
      onClose={onClose}
    >
      <TextField
        label="Número da aula"
        type="number"
        min={1}
        max={999}
        step={1}
        value={number}
        onChange={(event) => setNumber(event.target.value)}
        required
      />
      <TextField
        label="Nome"
        value={name}
        maxLength={160}
        onChange={(event) => setName(event.target.value)}
        required
      />
      <TextAreaField
        label="Descrição"
        hint="Uma frase sobre o que o assunto cobre."
        value={description}
        maxLength={500}
        onChange={(event) => setDescription(event.target.value)}
        required
      />
    </AdminFormModal>
  );
}
