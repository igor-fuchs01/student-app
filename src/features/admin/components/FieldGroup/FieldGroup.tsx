import type { ReactNode } from "react";
import { TextButton } from "@features/admin/components/TextButton";
import { StyledGroup, StyledLegend, StyledHint } from "./FieldGroup.styles";

type FieldGroupProps = {
  legend: string;
  hint?: string;
  addLabel?: string;
  onAdd?: () => void;
  children: ReactNode;
};

export function FieldGroup({ legend, hint, addLabel, onAdd, children }: FieldGroupProps) {
  return (
    <StyledGroup>
      <StyledLegend>{legend}</StyledLegend>
      {hint && <StyledHint>{hint}</StyledHint>}
      {children}
      {addLabel && onAdd && <TextButton onClick={onAdd}>+ {addLabel}</TextButton>}
    </StyledGroup>
  );
}
