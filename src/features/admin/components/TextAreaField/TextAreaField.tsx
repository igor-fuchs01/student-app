import { useId, type TextareaHTMLAttributes } from "react";
import { StyledField, StyledLabel, StyledTextArea, StyledHint } from "./TextAreaField.styles";

type TextAreaFieldProps = TextareaHTMLAttributes<HTMLTextAreaElement> & {
  label: string;
  hint?: string;
};

export function TextAreaField({ label, hint, id, ...rest }: TextAreaFieldProps) {
  const generatedId = useId();
  const fieldId = id ?? generatedId;
  const hintId = hint ? `${fieldId}-hint` : undefined;

  return (
    <StyledField>
      <StyledLabel htmlFor={fieldId}>{label}</StyledLabel>
      <StyledTextArea id={fieldId} aria-describedby={hintId} {...rest} />
      {hint && <StyledHint id={hintId}>{hint}</StyledHint>}
    </StyledField>
  );
}
