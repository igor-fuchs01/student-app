import styled from "styled-components";

export const StyledTableWrapper = styled.div`
  height: 100%;
  overflow: auto;
`;

export const StyledTable = styled.table`
  width: 100%;
  border-collapse: collapse;
  font-size: 12px;
`;

export const StyledHeaderCell = styled.th<{ $numeric: boolean }>`
  position: sticky;
  top: 0;
  background: ${({ theme }) => theme.colors.surface};
  text-align: ${({ $numeric }) => ($numeric ? "right" : "left")};
  font-size: 11px;
  font-weight: 600;
  color: ${({ theme }) => theme.colors.muted};
  padding: 0 8px 6px;
  border-bottom: 1px solid ${({ theme }) => theme.colors.divider};
  white-space: nowrap;
`;

export const StyledCell = styled.td<{ $numeric: boolean }>`
  text-align: ${({ $numeric }) => ($numeric ? "right" : "left")};
  font-variant-numeric: ${({ $numeric }) => ($numeric ? "tabular-nums" : "normal")};
  padding: 6px 8px;
  border-bottom: 1px solid ${({ theme }) => theme.colors.divider};
`;
