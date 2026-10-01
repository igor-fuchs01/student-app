import { useId } from "react";
import { DASHBOARD_PERIODS, type DashboardFilters as Filters } from "@models/dashboard";
import type { Subject } from "@models/subjects";
import {
  StyledFilters,
  StyledSegmented,
  StyledSegment,
  StyledSelect,
  StyledVisuallyHidden,
} from "./DashboardFilters.styles";

type DashboardFiltersProps = {
  filters: Filters;
  subjects: Subject[];
  onChange: (filters: Filters) => void;
};

const PERIOD_LABEL: Record<Filters["period"], string> = {
  30: "30 dias",
  90: "90 dias",
  180: "Semestre",
};

export function DashboardFilters({ filters, subjects, onChange }: DashboardFiltersProps) {
  const selectId = useId();

  return (
    <StyledFilters role="group" aria-label="Filtros do painel">
      <StyledSegmented role="group" aria-label="Período">
        {DASHBOARD_PERIODS.map((period) => (
          <StyledSegment
            key={period}
            type="button"
            $active={filters.period === period}
            aria-pressed={filters.period === period}
            onClick={() => onChange({ ...filters, period })}
          >
            {PERIOD_LABEL[period]}
          </StyledSegment>
        ))}
      </StyledSegmented>

      <StyledVisuallyHidden htmlFor={selectId}>Disciplina</StyledVisuallyHidden>
      <StyledSelect
        id={selectId}
        value={filters.subjectId ?? ""}
        onChange={(event) => onChange({ ...filters, subjectId: event.target.value || undefined })}
      >
        <option value="">Todas as disciplinas</option>
        {subjects.map((subject) => (
          <option key={subject.id} value={subject.id}>
            {subject.name}
          </option>
        ))}
      </StyledSelect>
    </StyledFilters>
  );
}
