import type { FormEvent, ReactNode } from "react";
import { Button } from "@components/ui/Button";
import { Modal } from "@components/ui/Modal";
import { ErrorNotice } from "@features/admin/components/ErrorNotice";
import { StyledForm, StyledTitle, StyledFields, StyledActions } from "./AdminFormModal.styles";

type AdminFormModalProps = {
  title: string;
  isSaving: boolean;
  error: Error | null;
  onSubmit: () => void;
  onClose: () => void;
  children: ReactNode;
};

export function AdminFormModal({
  title,
  isSaving,
  error,
  onSubmit,
  onClose,
  children,
}: AdminFormModalProps) {
  function handleSubmit(event: FormEvent<HTMLFormElement>) {
    event.preventDefault();
    onSubmit();
  }

  return (
    <Modal ariaLabel={title} onClose={onClose}>
      <StyledForm onSubmit={handleSubmit}>
        <StyledTitle>{title}</StyledTitle>
        <StyledFields>{children}</StyledFields>
        <ErrorNotice error={error} />
        <StyledActions>
          <Button type="button" variant="secondary" onClick={onClose} disabled={isSaving}>
            Cancelar
          </Button>
          <Button type="submit" isLoading={isSaving}>
            Salvar
          </Button>
        </StyledActions>
      </StyledForm>
    </Modal>
  );
}
