import styled from "styled-components";

export const StyledSparkline = styled.svg`
  flex: none;
  display: block;
  overflow: visible;
`;

export const StyledSparklinePath = styled.path`
  fill: none;
  stroke: ${({ theme }) => theme.colors.muted};
  stroke-opacity: 0.4;
  stroke-width: 2;
  stroke-linejoin: round;
  stroke-linecap: round;
`;

export const StyledSparklineDot = styled.circle`
  fill: ${({ theme }) => theme.colors.accent};
  stroke: ${({ theme }) => theme.colors.surface};
  stroke-width: 2;
`;
