import styled from "styled-components";
import { Card } from "@components/ui/Card";

export type DeltaDirection = "up" | "down" | "flat";

export const StyledKpiCard = styled(Card)`
  display: flex;
  flex-direction: column;
  gap: 4px;
  min-width: 0;
  border: 1px solid ${({ theme }) => theme.colors.divider};
  padding: 16px 22px;
`;

export const StyledLabel = styled.span`
  font-size: 12.5px;
  font-weight: 600;
  color: ${({ theme }) => theme.colors.muted};
`;

export const StyledRow = styled.div`
  display: flex;
  align-items: center;
  justify-content: space-between;
  gap: 10px;
`;

export const StyledValue = styled.span`
  font-size: 34px;
  font-weight: 700;
  line-height: 1.1;
  letter-spacing: -0.01em;
`;

export const StyledUnit = styled.small`
  font-size: 15px;
  font-weight: 600;
  color: ${({ theme }) => theme.colors.muted};
  margin-left: 4px;
`;

export const StyledFooter = styled.span`
  font-size: 12px;
  color: ${({ theme }) => theme.colors.muted};
  white-space: nowrap;
  overflow: hidden;
  text-overflow: ellipsis;
`;

export const StyledDelta = styled.span<{ $direction: DeltaDirection }>`
  font-weight: 700;
  color: ${({ theme, $direction }) =>
    $direction === "up"
      ? theme.colors.accent600
      : $direction === "down"
        ? theme.colors.danger600
        : theme.colors.muted};
`;
