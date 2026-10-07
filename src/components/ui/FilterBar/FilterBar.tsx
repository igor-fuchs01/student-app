import { useId } from "react";
import { StyledFilters, StyledSelect, StyledVisuallyHidden } from "./FilterBar.styles";

export type FilterOption = { value: string; label: string };

export type Filter = {
  label: string;
  allLabel: string;
  options: FilterOption[];
  value: string | undefined;
  disabled?: boolean;
  onChange: (value: string | undefined) => void;
};

type FilterBarProps = {
  label: string;
  filters: Filter[];
};

// A row of pill selects whose empty option means "no filter"; each select's label is only read by
// screen readers.
export function FilterBar({ label, filters }: FilterBarProps) {
  const baseId = useId();

  return (
    <StyledFilters role="group" aria-label={label}>
      {filters.map((filter, index) => {
        const selectId = `${baseId}-${index}`;
        return (
          <span key={filter.label}>
            <StyledVisuallyHidden htmlFor={selectId}>{filter.label}</StyledVisuallyHidden>
            <StyledSelect
              id={selectId}
              value={filter.value ?? ""}
              disabled={filter.disabled}
              onChange={(event) => filter.onChange(event.target.value || undefined)}
            >
              <option value="">{filter.allLabel}</option>
              {filter.options.map((option) => (
                <option key={option.value} value={option.value}>
                  {option.label}
                </option>
              ))}
            </StyledSelect>
          </span>
        );
      })}
    </StyledFilters>
  );
}
