import styled, { css } from "styled-components";
import { Card } from "@components/ui/Card";

export type LegendMark = "line" | "target";

export const StyledChartCard = styled(Card)`
  display: flex;
  flex-direction: column;
  min-width: 0;
  border: 1px solid ${({ theme }) => theme.colors.divider};
  min-height: 0;
  padding: 18px 22px;
  overflow: hidden;
`;

export const StyledHead = styled.div`
  flex: none;
  display: flex;
  align-items: flex-start;
  justify-content: space-between;
  gap: 12px;
  margin-bottom: 12px;
`;

export const StyledTitle = styled.h2`
  font-size: 15px;
  font-weight: 700;
  line-height: 1.3;
  margin: 0;
`;

export const StyledSubtitle = styled.p`
  font-size: 12.5px;
  color: ${({ theme }) => theme.colors.muted};
  margin: 2px 0 0;
`;

export const StyledToggle = styled.button`
  flex: none;
  border: 1px solid ${({ theme }) => theme.colors.divider};
  background: transparent;
  color: ${({ theme }) => theme.colors.muted};
  font-size: 11.5px;
  font-weight: 600;
  padding: 4px 10px;
  border-radius: ${({ theme }) => theme.radii.pill};
  white-space: nowrap;

  &:hover {
    color: ${({ theme }) => theme.colors.text};
  }
`;

export const StyledBody = styled.div`
  position: relative;
  flex: 1;
  min-height: 240px;

  @media (min-width: ${({ theme }) => theme.breakpoints.md}) and (min-height: 560px) {
    min-height: 0;
  }
`;

export const StyledLegend = styled.div`
  flex: none;
  display: flex;
  align-items: center;
  flex-wrap: wrap;
  gap: 4px 14px;
  margin-top: 10px;
  font-size: 11.5px;
  color: ${({ theme }) => theme.colors.muted};
`;

export const StyledLegendItem = styled.span`
  display: inline-flex;
  align-items: center;
  gap: 6px;
`;

export const StyledLegendMark = styled.span<{ $mark: LegendMark }>`
  width: 14px;

  ${({ theme, $mark }) =>
    $mark === "line"
      ? css`
          height: 2px;
          border-radius: 2px;
          background: ${theme.colors.accent};
        `
      : css`
          border-top: 1px dashed ${theme.colors.muted};
        `}
`;
