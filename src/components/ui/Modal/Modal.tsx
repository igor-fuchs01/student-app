import type { ReactNode } from "react";
import { StyledOverlay, StyledModalCard } from "./Modal.styles";

type ModalProps = {
  children: ReactNode;
  ariaLabel: string;
};

export function Modal({ children, ariaLabel }: ModalProps) {
  return (
    <StyledOverlay role="dialog" aria-modal="true" aria-label={ariaLabel}>
      <StyledModalCard tone="surface">{children}</StyledModalCard>
    </StyledOverlay>
  );
}
