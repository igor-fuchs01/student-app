import type { InputHTMLAttributes } from "react";
import { useId } from "react";
import { StyledField, StyledLabel, StyledInput, StyledErrorText } from "./TextField.styles";

type TextFieldProps = InputHTMLAttributes<HTMLInputElement> & {
  label: string;
  errorMessage?: string;
};

export function TextField({ label, errorMessage, id, ...rest }: TextFieldProps) {
  const generatedId = useId();
  const inputId = id ?? generatedId;
  const errorId = errorMessage ? `${inputId}-error` : undefined;

  return (
    <StyledField>
      <StyledLabel htmlFor={inputId}>{label}</StyledLabel>
      <StyledInput
        id={inputId}
        aria-invalid={Boolean(errorMessage)}
        aria-describedby={errorId}
        {...rest}
      />
      {errorMessage && (
        <StyledErrorText id={errorId} role="alert">
          {errorMessage}
        </StyledErrorText>
      )}
    </StyledField>
  );
}
