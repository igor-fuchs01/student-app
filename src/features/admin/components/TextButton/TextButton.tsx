import type { ButtonHTMLAttributes } from "react";
import { StyledTextButton, type TextButtonTone } from "./TextButton.styles";

type TextButtonProps = ButtonHTMLAttributes<HTMLButtonElement> & {
  tone?: TextButtonTone;
};

export function TextButton({ tone = "accent", type = "button", ...rest }: TextButtonProps) {
  return <StyledTextButton $tone={tone} type={type} {...rest} />;
}
