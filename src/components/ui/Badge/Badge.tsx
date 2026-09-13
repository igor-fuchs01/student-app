import type { ReactNode } from "react";
import { StyledBadge, type BadgeTone } from "./Badge.styles";

type BadgeProps = {
  tone?: BadgeTone;
  children: ReactNode;
};

export function Badge({ tone = "neutral", children }: BadgeProps) {
  return <StyledBadge $tone={tone}>{children}</StyledBadge>;
}
