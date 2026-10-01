import { useState, type KeyboardEvent, type PointerEvent } from "react";
import type { WeeklyAccuracy } from "@models/dashboard";
import { useElementSize } from "@features/dashboard/hooks/useElementSize";
import { formatPercent, PREPARATION_TARGET } from "@features/dashboard/percent";
import { ChartTable } from "../ChartTable";
import { ChartTooltip } from "../ChartTooltip";
import {
  StyledChartArea,
  StyledAxisText,
  StyledGridLine,
  StyledTargetLine,
  StyledArea,
  StyledLine,
  StyledDot,
  StyledLastValue,
  StyledCrosshair,
  StyledHitArea,
  StyledEmpty,
} from "./AccuracyTrendChart.styles";

type AccuracyTrendChartProps = {
  weeks: WeeklyAccuracy[];
  showTable: boolean;
};

const MARGIN = { left: 36, right: 12, top: 18, bottom: 22 };

function formatDayMonth(isoDate: string): string {
  const [, month, day] = isoDate.split("-");
  return `${day}/${month}`;
}

function weekLabel(week: WeeklyAccuracy): string {
  return `${formatDayMonth(week.weekStart)} – ${formatDayMonth(week.weekEnd)}`;
}

export function AccuracyTrendChart({ weeks, showTable }: AccuracyTrendChartProps) {
  const { ref, width, height } = useElementSize<HTMLDivElement>();
  const [activeIndex, setActiveIndex] = useState<number | null>(null);
  const lastIndex = weeks.map((week) => week.percent !== null).lastIndexOf(true);

  if (showTable) {
    return (
      <ChartTable
        columns={[
          { label: "Semana" },
          { label: "Respondidas", numeric: true },
          { label: "Corrigidas", numeric: true },
          { label: "Acerto", numeric: true },
        ]}
        rows={[...weeks].reverse().map((week) => ({
          key: week.weekStart,
          cells: [
            weekLabel(week),
            week.answeredCount,
            week.gradedCount,
            formatPercent(week.percent),
          ],
        }))}
      />
    );
  }

  if (lastIndex === -1) {
    return <StyledEmpty>Nenhuma questão corrigida neste período.</StyledEmpty>;
  }

  const plotWidth = Math.max(0, width - MARGIN.left - MARGIN.right);
  const plotHeight = Math.max(0, height - MARGIN.top - MARGIN.bottom);
  const count = weeks.length;
  const x = (index: number) =>
    MARGIN.left + (count === 1 ? plotWidth / 2 : (index * plotWidth) / (count - 1));
  const y = (value: number) => MARGIN.top + plotHeight * (1 - value / 100);

  const ticks = plotHeight < 150 ? [0, 50, 100] : [0, 25, 50, 75, 100];
  const labelStep = Math.ceil(count / Math.max(2, Math.floor(plotWidth / 64)));

  const segments: [number, number][][] = [];
  weeks.forEach((week, index) => {
    if (week.percent === null) {
      segments.push([]);
    } else {
      if (segments.length === 0) segments.push([]);
      segments[segments.length - 1].push([index, week.percent]);
    }
  });
  const drawn = segments.filter((segment) => segment.length > 0);
  const linePath = drawn
    .map((segment) =>
      segment.map(([index, value], i) => `${i ? "L" : "M"}${x(index)},${y(value)}`).join(""),
    )
    .join("");
  const areaPath = drawn
    .map(
      (segment) =>
        `M${x(segment[0][0])},${y(0)}` +
        segment.map(([index, value]) => `L${x(index)},${y(value)}`).join("") +
        `L${x(segment[segment.length - 1][0])},${y(0)}Z`,
    )
    .join("");

  const last = weeks[lastIndex];
  const active = activeIndex === null ? null : weeks[activeIndex];

  function handlePointerMove(event: PointerEvent<SVGRectElement>) {
    const left = event.currentTarget.ownerSVGElement?.getBoundingClientRect().left ?? 0;
    const ratio = (event.clientX - left - MARGIN.left) / Math.max(1, plotWidth);
    setActiveIndex(Math.max(0, Math.min(count - 1, Math.round(ratio * (count - 1)))));
  }

  function handleKeyDown(event: KeyboardEvent<SVGRectElement>) {
    if (event.key !== "ArrowLeft" && event.key !== "ArrowRight") return;
    event.preventDefault();
    const step = event.key === "ArrowRight" ? 1 : -1;
    setActiveIndex((current) => Math.max(0, Math.min(count - 1, (current ?? lastIndex) + step)));
  }

  return (
    <StyledChartArea ref={ref}>
      {width > 0 && height > 0 && (
        <svg
          width={width}
          height={height}
          role="img"
          aria-label={`Acerto semanal; última semana com ${formatPercent(last.percent)}`}
        >
          {ticks.map((tick) => (
            <g key={tick}>
              <StyledGridLine
                $baseline={tick === 0}
                x1={MARGIN.left}
                x2={width - MARGIN.right}
                y1={y(tick)}
                y2={y(tick)}
              />
              <StyledAxisText x={MARGIN.left - 8} y={y(tick) + 4} textAnchor="end">
                {tick}%
              </StyledAxisText>
            </g>
          ))}
          <StyledTargetLine
            x1={MARGIN.left}
            x2={width - MARGIN.right}
            y1={y(PREPARATION_TARGET)}
            y2={y(PREPARATION_TARGET)}
          />
          <StyledArea d={areaPath} />
          <StyledLine d={linePath} />
          {weeks.map((week, index) =>
            (count - 1 - index) % labelStep === 0 ? (
              <StyledAxisText key={week.weekStart} x={x(index)} y={height - 5} textAnchor="middle">
                {formatDayMonth(week.weekStart)}
              </StyledAxisText>
            ) : null,
          )}
          <StyledDot cx={x(lastIndex)} cy={y(last.percent ?? 0)} r={4.5} />
          <StyledLastValue
            x={x(lastIndex)}
            y={y(last.percent ?? 0) - 11}
            textAnchor={lastIndex > count / 2 ? "end" : "middle"}
          >
            {formatPercent(last.percent)}
          </StyledLastValue>
          {active && activeIndex !== null && (
            <g>
              <StyledCrosshair
                x1={x(activeIndex)}
                x2={x(activeIndex)}
                y1={MARGIN.top}
                y2={MARGIN.top + plotHeight}
              />
              {active.percent !== null && (
                <StyledDot cx={x(activeIndex)} cy={y(active.percent)} r={4.5} />
              )}
            </g>
          )}
          <StyledHitArea
            x={MARGIN.left - 10}
            y={MARGIN.top}
            width={plotWidth + 20}
            height={plotHeight}
            tabIndex={0}
            aria-label="Explorar as semanas com as setas do teclado"
            onPointerMove={handlePointerMove}
            onPointerLeave={() => setActiveIndex(null)}
            onFocus={() => setActiveIndex(lastIndex)}
            onBlur={() => setActiveIndex(null)}
            onKeyDown={handleKeyDown}
          />
        </svg>
      )}
      {active && activeIndex !== null && (
        <ChartTooltip x={x(activeIndex)} y={y(active.percent ?? 50)} title={weekLabel(active)}>
          Acerto: <b>{formatPercent(active.percent)}</b>
          <br />
          {active.correctCount} de {active.gradedCount} corrigidas · {active.answeredCount}{" "}
          respondidas
        </ChartTooltip>
      )}
    </StyledChartArea>
  );
}
