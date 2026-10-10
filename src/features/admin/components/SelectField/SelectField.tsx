import { useId, type SelectHTMLAttributes } from "react";
import { StyledField, StyledLabel, StyledSelect } from "./SelectField.styles";

type SelectFieldProps = Omit<SelectHTMLAttributes<HTMLSelectElement>, "value" | "onChange"> & {
  label: string;
  options: { value: string; label: string }[];
  value: string;
  placeholder?: string;
  onChange: (value: string) => void;
};

export function SelectField({
  label,
  options,
  value,
  placeholder,
  onChange,
  id,
  ...rest
}: SelectFieldProps) {
  const generatedId = useId();
  const fieldId = id ?? generatedId;

  return (
    <StyledField>
      <StyledLabel htmlFor={fieldId}>{label}</StyledLabel>
      <StyledSelect
        id={fieldId}
        value={value}
        onChange={(event) => onChange(event.target.value)}
        {...rest}
      >
        {placeholder !== undefined && <option value="">{placeholder}</option>}
        {options.map((option) => (
          <option key={option.value} value={option.value}>
            {option.label}
          </option>
        ))}
      </StyledSelect>
    </StyledField>
  );
}
