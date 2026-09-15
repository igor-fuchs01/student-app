import styled from "styled-components";
import { Card } from "@components/ui/Card";

export const StyledPageTitle = styled.h1`
  font-family: ${({ theme }) => theme.fonts.heading};
  font-weight: 700;
  font-size: 20px;
  margin: 0 0 4px;
`;

export const StyledPageSubtitle = styled.p`
  color: ${({ theme }) => theme.colors.muted};
  font-size: 13px;
  margin: 0 0 20px;
  max-width: 640px;
`;

export const StyledTableCard = styled(Card)`
  padding: 0;
  overflow-x: auto;
`;

export const StyledTable = styled.table`
  width: 100%;
  min-width: 640px;
  table-layout: fixed;
  border-collapse: collapse;
  font-size: 13.5px;
`;

export const StyledCol = styled.col<{ $width: string }>`
  width: ${({ $width }) => $width};
`;

export const StyledTableHead = styled.thead`
  text-align: left;
  color: ${({ theme }) => theme.colors.muted};
  font-size: 11px;
  letter-spacing: 0.05em;
  text-transform: uppercase;

  th {
    padding: 14px 18px;
  }
`;

export const StyledTableRow = styled.tr`
  border-top: 1px solid ${({ theme }) => theme.colors.divider};

  td {
    padding: 14px 18px;
  }

  td:first-child {
    padding-left: 18px;
  }

  &:hover {
    background: ${({ theme }) => theme.colors.accent100};
  }

  &:hover td:last-child button:not(:disabled) {
    background: ${({ theme }) => theme.colors.accent};
    color: #fff;
    border-color: transparent;
  }
`;

export const StyledQuizTitle = styled.td`
  overflow: hidden;
  white-space: nowrap;
  text-overflow: ellipsis;

  ${StyledTableRow}:hover & {
    font-weight: 700;
  }
`;

export const StyledSubjectBadge = styled.span<{ $integrated?: boolean }>`
  background: ${({ theme, $integrated }) => ($integrated ? theme.colors.accent : "transparent")};
  color: ${({ theme, $integrated }) => ($integrated ? "#fff" : theme.colors.text)};
  font-size: 11px;
  font-weight: 700;
  padding: 3px 12px;
  border-radius: ${({ theme }) => theme.radii.pill};
`;
