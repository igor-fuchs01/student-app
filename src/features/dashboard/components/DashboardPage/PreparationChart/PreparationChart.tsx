import { useState, type SyntheticEvent } from "react";
import type { DashboardData, PreparationItem } from "@models/dashboard";
import { formatPercent, PREPARATION_TARGET } from "@features/dashboard/percent";
import { ChartTable } from "../ChartTable";
import { ChartTooltip } from "../ChartTooltip";
import {
  StyledBars,
  StyledBarRow,
  StyledBarName,
  StyledBarLabel,
  StyledBarSub,
  StyledBarTrack,
  StyledBarArea,
  StyledBarFill,
  StyledBarTarget,
  StyledBarValue,
  StyledEmpty,
} from "./PreparationChart.styles";

type PreparationChartProps = {
  breakdown: DashboardData["preparationBreakdown"];
  showTable: boolean;
};

type ActiveBar = { item: PreparationItem; x: number; y: number };

export function PreparationChart({ breakdown, showTable }: PreparationChartProps) {
  const [active, setActive] = useState<ActiveBar | null>(null);

  if (breakdown.items.length === 0) {
    return <StyledEmpty>Nenhuma questão corrigida neste período.</StyledEmpty>;
  }

  if (showTable) {
    return (
      <ChartTable
        columns={[
          { label: breakdown.scope === "topic" ? "Assunto" : "Disciplina" },
          { label: "Corrigidas", numeric: true },
          { label: "Acertos", numeric: true },
          { label: "Acerto", numeric: true },
        ]}
        rows={breakdown.items.map((item) => ({
          key: item.id,
          cells: [item.name, item.gradedCount, item.correctCount, formatPercent(item.percent)],
        }))}
      />
    );
  }

  function showTooltip(item: PreparationItem, event: SyntheticEvent<HTMLDivElement>) {
    const row = event.currentTarget;
    setActive({ item, x: row.offsetLeft + row.offsetWidth / 2, y: row.offsetTop });
  }

  return (
    <StyledBars>
      {breakdown.items.map((item) => (
        <StyledBarRow
          key={item.id}
          tabIndex={0}
          aria-label={`${item.name}: ${formatPercent(item.percent)} de acerto`}
          onPointerEnter={(event) => showTooltip(item, event)}
          onPointerLeave={() => setActive(null)}
          onFocus={(event) => showTooltip(item, event)}
          onBlur={() => setActive(null)}
        >
          <StyledBarName>
            <StyledBarLabel>{item.name}</StyledBarLabel>
            {item.topicNumber !== undefined && <StyledBarSub>Aula {item.topicNumber}</StyledBarSub>}
          </StyledBarName>
          <StyledBarTrack>
            <StyledBarArea>
              <StyledBarFill $value={item.percent} />
              <StyledBarTarget $value={PREPARATION_TARGET} />
            </StyledBarArea>
            <StyledBarValue>{formatPercent(item.percent)}</StyledBarValue>
          </StyledBarTrack>
        </StyledBarRow>
      ))}
      {active && (
        <ChartTooltip x={active.x} y={active.y} title={active.item.name}>
          Acerto: <b>{formatPercent(active.item.percent)}</b>
          <br />
          {active.item.correctCount} de {active.item.gradedCount} questões corrigidas
        </ChartTooltip>
      )}
    </StyledBars>
  );
}
