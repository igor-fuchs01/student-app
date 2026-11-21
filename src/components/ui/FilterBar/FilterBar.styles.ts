import styled from "styled-components";

export const StyledFilters = styled.div`
  display: flex;
  align-items: center;
  gap: 10px;
  flex-wrap: wrap;
  margin-bottom: 8px;
`;

export const StyledSelect = styled.select`
  appearance: none;
  min-height: 44px;
  background-color: ${({ theme }) => theme.colors.surface};
  background-image: url("data:image/svg+xml,%3Csvg xmlns='http://www.w3.org/2000/svg' width='10' height='6'%3E%3Cpath d='M1 1l4 4 4-4' fill='none' stroke='%23888' stroke-width='1.6'/%3E%3C/svg%3E");
  background-repeat: no-repeat;
  background-position: right 12px center;
  border: 1px solid ${({ theme }) => theme.colors.divider};
  border-radius: ${({ theme }) => theme.radii.pill};
  color: ${({ theme }) => theme.colors.text};
  padding: 7px 34px 7px 14px;
  font-size: 12.5px;
  font-weight: 600;

  &:disabled {
    color: ${({ theme }) => theme.colors.muted};
    cursor: not-allowed;
  }

  &:focus-visible {
    outline: 2px solid ${({ theme }) => theme.colors.accent};
    outline-offset: 1px;
  }
`;

export const StyledVisuallyHidden = styled.label`
  position: absolute;
  width: 1px;
  height: 1px;
  overflow: hidden;
  clip: rect(0 0 0 0);
  white-space: nowrap;
`;

export const StyledCheckboxGroup = styled.div`
  display: flex;
  align-items: center;
  gap: 6px;
  flex-wrap: wrap;
`;

export const StyledCheckboxGroupLabel = styled.span`
  color: ${({ theme }) => theme.colors.muted};
  font-size: 12.5px;
  font-weight: 600;
  margin: 0 2px 0 4px;
`;

export const StyledCheckboxChip = styled.label<{ $checked: boolean }>`
  display: inline-flex;
  align-items: center;
  gap: 6px;
  min-height: 44px;
  padding: 7px 14px 7px 10px;
  border: 1px solid
    ${({ theme, $checked }) => ($checked ? theme.colors.accent : theme.colors.divider)};
  border-radius: ${({ theme }) => theme.radii.pill};
  background: ${({ theme, $checked }) => ($checked ? theme.colors.accent100 : theme.colors.surface)};
  color: ${({ theme, $checked }) => ($checked ? theme.colors.accent600 : theme.colors.text)};
  font-size: 12.5px;
  font-weight: 600;
  cursor: pointer;

  input {
    margin: 0;
    accent-color: ${({ theme }) => theme.colors.accent};
  }

  &:has(input:focus-visible) {
    outline: 2px solid ${({ theme }) => theme.colors.accent};
    outline-offset: 1px;
  }
`;
