import type { HTMLAttributes } from "react";
import { StyledBadge, type BadgeTone } from "./Badge.styles";

type BadgeProps = HTMLAttributes<HTMLSpanElement> & {
  tone?: BadgeTone;
};

export function Badge({ tone = "neutral", ...rest }: BadgeProps) {
  return <StyledBadge $tone={tone} {...rest} />;
}
