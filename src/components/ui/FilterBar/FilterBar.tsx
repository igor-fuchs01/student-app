import { useId } from "react";
import {
  StyledFilters,
  StyledSelect,
  StyledVisuallyHidden,
  StyledCheckboxGroup,
  StyledCheckboxGroupLabel,
  StyledCheckboxChip,
} from "./FilterBar.styles";

export type FilterOption = { value: string; label: string };

type SelectFilter = {
  type?: "select";
  label: string;
  allLabel: string;
  options: FilterOption[];
  value: string | undefined;
  disabled?: boolean;
  onChange: (value: string | undefined) => void;
};

// Several options may be checked at once; none checked means "no filter".
type CheckboxFilter = {
  type: "checkboxes";
  label: string;
  options: FilterOption[];
  values: string[];
  onChange: (values: string[]) => void;
};

export type Filter = SelectFilter | CheckboxFilter;

type FilterBarProps = {
  label: string;
  filters: Filter[];
};

// A row of filters: pill selects whose empty option means "no filter", with a label only read by
// screen readers, and groups of checkbox chips with a visible label.
export function FilterBar({ label, filters }: FilterBarProps) {
  const baseId = useId();

  return (
    <StyledFilters role="group" aria-label={label}>
      {filters.map((filter, index) => {
        const filterId = `${baseId}-${index}`;

        if (filter.type === "checkboxes") {
          return (
            <StyledCheckboxGroup key={filter.label} role="group" aria-labelledby={filterId}>
              <StyledCheckboxGroupLabel id={filterId}>{filter.label}</StyledCheckboxGroupLabel>
              {filter.options.map((option) => {
                const checked = filter.values.includes(option.value);
                return (
                  <StyledCheckboxChip key={option.value} $checked={checked}>
                    <input
                      type="checkbox"
                      checked={checked}
                      onChange={() =>
                        filter.onChange(
                          checked
                            ? filter.values.filter((value) => value !== option.value)
                            : [...filter.values, option.value],
                        )
                      }
                    />
                    {option.label}
                  </StyledCheckboxChip>
                );
              })}
            </StyledCheckboxGroup>
          );
        }

        return (
          <span key={filter.label}>
            <StyledVisuallyHidden htmlFor={filterId}>{filter.label}</StyledVisuallyHidden>
            <StyledSelect
              id={filterId}
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
