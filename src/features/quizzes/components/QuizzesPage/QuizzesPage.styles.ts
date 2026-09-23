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

  @media (max-width: ${({ theme }) => theme.breakpoints.sm}) {
    overflow: visible;
    background: transparent;
    box-shadow: none;
  }
`;

export const StyledTable = styled.table`
  width: 100%;
  min-width: 640px;
  table-layout: fixed;
  border-collapse: collapse;
  font-size: 13.5px;

  @media (max-width: ${({ theme }) => theme.breakpoints.sm}) {
    display: block;
    min-width: 0;

    colgroup {
      display: none;
    }

    tbody {
      display: flex;
      flex-direction: column;
      gap: 12px;
    }
  }
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

  @media (max-width: ${({ theme }) => theme.breakpoints.sm}) {
    position: absolute;
    width: 1px;
    height: 1px;
    overflow: hidden;
    clip-path: inset(50%);
    white-space: nowrap;
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

  @media (max-width: ${({ theme }) => theme.breakpoints.sm}) {
    display: flex;
    flex-wrap: wrap;
    align-items: center;
    gap: 6px 8px;
    padding: 16px;
    border-top: none;
    border-radius: ${({ theme }) => theme.radii.lg};
    background: ${({ theme }) => theme.colors.surface};
    box-shadow: ${({ theme }) => theme.shadows.sm};

    &:hover {
      background: ${({ theme }) => theme.colors.surface};
    }

    td,
    td:first-child {
      padding: 0;
    }

    td:nth-child(n + 3):nth-child(-n + 6) {
      color: ${({ theme }) => theme.colors.muted};
      font-size: 12.5px;
    }

    td:nth-child(n + 4):nth-child(-n + 6)::before {
      content: "· ";
    }

    td:first-child,
    td:nth-child(2),
    td:last-child {
      flex-basis: 100%;
    }

    td:last-child {
      margin-top: 8px;
    }

    td:last-child button {
      width: 100%;
    }

    td:last-child button:not(:disabled) {
      background: ${({ theme }) => theme.colors.accent};
      color: #fff;
      border-color: transparent;
    }
  }
`;

export const StyledQuizTitle = styled.td`
  overflow: hidden;
  white-space: nowrap;
  text-overflow: ellipsis;

  ${StyledTableRow}:hover & {
    font-weight: 700;
  }

  @media (max-width: ${({ theme }) => theme.breakpoints.sm}) {
    font-family: ${({ theme }) => theme.fonts.heading};
    font-size: 15px;
    font-weight: 700;
    white-space: normal;
  }
`;

export const StyledSubjectBadge = styled.span<{ $integrated?: boolean }>`
  background: ${({ theme, $integrated }) => ($integrated ? theme.colors.accent : "transparent")};
  color: ${({ theme, $integrated }) => ($integrated ? "#fff" : theme.colors.text)};
  font-size: 11px;
  font-weight: 700;
  padding: 3px 12px;
  border-radius: ${({ theme }) => theme.radii.pill};

  @media (max-width: ${({ theme }) => theme.breakpoints.sm}) {
    padding: ${({ $integrated }) => ($integrated ? "3px 12px" : "0")};
  }
`;
