import type { ReactNode } from "react";
import {
  StyledKpiCard,
  StyledLabel,
  StyledRow,
  StyledValue,
  StyledUnit,
  StyledFooter,
  StyledDelta,
} from "./KpiCard.styles";

export type KpiDelta = {
  current: number | null;
  previous: number | null;
  unit: "points" | "percent";
  comparisonLabel: string;
};

type KpiCardProps = {
  label: string;
  value: string;
  unit?: string;
  delta?: KpiDelta;
  aside?: ReactNode;
  children?: ReactNode;
};

function Delta({ current, previous, unit, comparisonLabel }: KpiDelta) {
  if (current === null || previous === null || (unit === "percent" && previous === 0)) {
    return <StyledDelta $direction="flat">sem comparação</StyledDelta>;
  }

  const change =
    unit === "points"
      ? Math.round(current - previous)
      : Math.round((100 * (current - previous)) / previous);
  if (change === 0) {
    return (
      <>
        <StyledDelta $direction="flat">= estável</StyledDelta> {comparisonLabel}
      </>
    );
  }

  const suffix = unit === "points" ? " p.p." : "%";
  return (
    <>
      <StyledDelta $direction={change > 0 ? "up" : "down"}>
        {change > 0 ? "▲" : "▼"} {Math.abs(change)}
        {suffix}
      </StyledDelta>{" "}
      {comparisonLabel}
    </>
  );
}

export function KpiCard({ label, value, unit, delta, aside, children }: KpiCardProps) {
  return (
    <StyledKpiCard as="article">
      <StyledLabel>{label}</StyledLabel>
      <StyledRow>
        <StyledValue>
          {value}
          {unit && <StyledUnit>{unit}</StyledUnit>}
        </StyledValue>
        {aside}
      </StyledRow>
      {delta && (
        <StyledFooter>
          <Delta {...delta} />
        </StyledFooter>
      )}
      {children}
    </StyledKpiCard>
  );
}
