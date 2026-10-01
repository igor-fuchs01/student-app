import { useId, useState, type ReactNode } from "react";
import {
  StyledChartCard,
  StyledHead,
  StyledTitle,
  StyledSubtitle,
  StyledToggle,
  StyledBody,
  StyledLegend,
  StyledLegendItem,
  StyledLegendMark,
  type LegendMark,
} from "./ChartCard.styles";

type ChartCardProps = {
  title: string;
  subtitle: string;
  legend: { mark: LegendMark; label: string }[];
  children: (showTable: boolean) => ReactNode;
};

export function ChartCard({ title, subtitle, legend, children }: ChartCardProps) {
  const titleId = useId();
  const [showTable, setShowTable] = useState(false);

  return (
    <StyledChartCard as="section" aria-labelledby={titleId}>
      <StyledHead>
        <div>
          <StyledTitle id={titleId}>{title}</StyledTitle>
          <StyledSubtitle>{subtitle}</StyledSubtitle>
        </div>
        <StyledToggle type="button" onClick={() => setShowTable((current) => !current)}>
          {showTable ? "Ver gráfico" : "Ver tabela"}
        </StyledToggle>
      </StyledHead>
      <StyledBody>{children(showTable)}</StyledBody>
      {!showTable && (
        <StyledLegend>
          {legend.map((item) => (
            <StyledLegendItem key={item.label}>
              <StyledLegendMark $mark={item.mark} aria-hidden="true" />
              {item.label}
            </StyledLegendItem>
          ))}
        </StyledLegend>
      )}
    </StyledChartCard>
  );
}
