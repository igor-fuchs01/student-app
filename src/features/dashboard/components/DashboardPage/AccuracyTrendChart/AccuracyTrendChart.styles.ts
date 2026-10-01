import styled from "styled-components";

export const StyledChartArea = styled.div`
  position: absolute;
  inset: 0;

  svg {
    display: block;
    overflow: visible;
  }
`;

export const StyledAxisText = styled.text`
  font-size: 11px;
  fill: ${({ theme }) => theme.colors.muted};
  font-variant-numeric: tabular-nums;
`;

export const StyledGridLine = styled.line<{ $baseline: boolean }>`
  stroke: ${({ theme, $baseline }) => ($baseline ? theme.colors.muted : theme.colors.divider)};
  stroke-opacity: ${({ $baseline }) => ($baseline ? 0.5 : 1)};
`;

export const StyledTargetLine = styled.line`
  stroke: ${({ theme }) => theme.colors.muted};
  stroke-dasharray: 4 4;
`;

export const StyledArea = styled.path`
  fill: ${({ theme }) => theme.colors.accent100};
  fill-opacity: 0.7;
`;

export const StyledLine = styled.path`
  fill: none;
  stroke: ${({ theme }) => theme.colors.accent};
  stroke-width: 2;
  stroke-linejoin: round;
  stroke-linecap: round;
`;

export const StyledDot = styled.circle`
  fill: ${({ theme }) => theme.colors.accent};
  stroke: ${({ theme }) => theme.colors.surface};
  stroke-width: 2;
`;

export const StyledLastValue = styled.text`
  fill: ${({ theme }) => theme.colors.text};
  font-size: 12px;
  font-weight: 700;
`;

export const StyledCrosshair = styled.line`
  stroke: ${({ theme }) => theme.colors.muted};
  stroke-opacity: 0.5;
`;

export const StyledHitArea = styled.rect`
  fill: transparent;

  &:focus-visible {
    outline: 2px solid ${({ theme }) => theme.colors.accent};
  }
`;

export const StyledEmpty = styled.p`
  height: 100%;
  display: grid;
  place-items: center;
  margin: 0;
  color: ${({ theme }) => theme.colors.muted};
  font-size: 13px;
`;
