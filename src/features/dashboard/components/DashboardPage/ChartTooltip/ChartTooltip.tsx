import type { ReactNode } from "react";
import { StyledChartTooltip, StyledChartTooltipTitle } from "./ChartTooltip.styles";

type ChartTooltipProps = {
  x: number;
  y: number;
  title: string;
  children: ReactNode;
};

export function ChartTooltip({ x, y, title, children }: ChartTooltipProps) {
  return (
    <StyledChartTooltip role="tooltip" style={{ left: x, top: y }}>
      <StyledChartTooltipTitle>{title}</StyledChartTooltipTitle>
      {children}
    </StyledChartTooltip>
  );
}
