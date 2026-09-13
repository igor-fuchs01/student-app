import type { ButtonHTMLAttributes } from "react";
import { StyledButton, type ButtonVariant } from "./Button.styles";

type ButtonProps = ButtonHTMLAttributes<HTMLButtonElement> & {
  variant?: ButtonVariant;
  isLoading?: boolean;
};

export function Button({
  variant = "primary",
  isLoading = false,
  disabled,
  children,
  ...rest
}: ButtonProps) {
  return (
    <StyledButton
      $variant={variant}
      disabled={disabled || isLoading}
      aria-busy={isLoading}
      {...rest}
    >
      {isLoading ? "Carregando…" : children}
    </StyledButton>
  );
}
