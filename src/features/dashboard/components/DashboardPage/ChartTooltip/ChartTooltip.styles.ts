import styled from "styled-components";

export const StyledChartTooltip = styled.div`
  position: absolute;
  z-index: 2;
  pointer-events: none;
  transform: translate(-50%, calc(-100% - 12px));
  background: ${({ theme }) => theme.colors.text};
  color: ${({ theme }) => theme.colors.surface};
  font-size: 12px;
  line-height: 1.45;
  padding: 8px 10px;
  border-radius: 10px;
  white-space: nowrap;
  box-shadow: ${({ theme }) => theme.shadows.md};
`;

export const StyledChartTooltipTitle = styled.div`
  font-weight: 700;
  margin-bottom: 2px;
`;
