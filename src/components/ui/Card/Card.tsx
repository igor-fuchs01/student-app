import type { HTMLAttributes } from "react";
import { StyledCard, type CardTone } from "./Card.styles";

type CardProps = HTMLAttributes<HTMLDivElement> & {
  tone?: CardTone;
};

export function Card({ tone = "surface", ...rest }: CardProps) {
  return <StyledCard $tone={tone} {...rest} />;
}
