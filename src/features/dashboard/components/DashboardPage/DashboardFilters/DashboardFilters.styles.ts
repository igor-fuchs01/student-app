import styled from "styled-components";

export const StyledFilters = styled.div`
  display: flex;
  align-items: center;
  gap: 10px;
  flex-wrap: wrap;
`;

export const StyledSegmented = styled.div`
  display: inline-flex;
  background: ${({ theme }) => theme.colors.surface};
  border: 1px solid ${({ theme }) => theme.colors.divider};
  border-radius: ${({ theme }) => theme.radii.pill};
  padding: 3px;
`;

export const StyledSegment = styled.button<{ $active: boolean }>`
  border: 0;
  background: ${({ theme, $active }) => ($active ? theme.colors.accent100 : "transparent")};
  color: ${({ theme, $active }) => ($active ? theme.colors.accent600 : theme.colors.muted)};
  padding: 5px 12px;
  font-size: 12.5px;
  font-weight: 600;
  border-radius: ${({ theme }) => theme.radii.pill};
`;

export const StyledSelect = styled.select`
  appearance: none;
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
`;

export const StyledVisuallyHidden = styled.label`
  position: absolute;
  width: 1px;
  height: 1px;
  overflow: hidden;
  clip: rect(0 0 0 0);
  white-space: nowrap;
`;
