import { useState } from "react";
import { useMutation, useQueryClient } from "@tanstack/react-query";
import { TextField } from "@components/ui/TextField";
import { AdminFormModal } from "@features/admin/components/AdminFormModal";
import { adminApi } from "@services/api/adminApi";
import type { AdminSubject } from "@models/admin";

type SubjectFormProps = {
  subject?: AdminSubject;
  onClose: () => void;
};

export function SubjectForm({ subject, onClose }: SubjectFormProps) {
  const queryClient = useQueryClient();
  const [name, setName] = useState(subject?.name ?? "");
  const [shortLabel, setShortLabel] = useState(subject?.shortLabel ?? "");

  const save = useMutation({
    mutationFn: adminApi.saveSubject,
    onSuccess: async () => {
      await queryClient.invalidateQueries({ queryKey: ["admin", "content"] });
      onClose();
    },
  });

  return (
    <AdminFormModal
      title={subject ? "Editar disciplina" : "Nova disciplina"}
      isSaving={save.isPending}
      error={save.error}
      onSubmit={() => save.mutate({ id: subject?.id, name, shortLabel })}
      onClose={onClose}
    >
      <TextField
        label="Nome"
        value={name}
        maxLength={120}
        onChange={(event) => setName(event.target.value)}
        required
      />
      <TextField
        label="Sigla"
        placeholder="Ex.: BD"
        value={shortLabel}
        maxLength={12}
        onChange={(event) => setShortLabel(event.target.value)}
        required
      />
    </AdminFormModal>
  );
}
