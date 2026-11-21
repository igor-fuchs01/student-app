import styled from "styled-components";

export const StyledTrack = styled.div`
  height: 10px;
  background: ${({ theme }) => theme.colors.neutral100};
  border-radius: ${({ theme }) => theme.radii.pill};
`;

export const StyledFill = styled.div<{ $value: number }>`
  height: 100%;
  width: ${({ $value }) => $value}%;
  background: ${({ theme }) => theme.colors.accent};
  border-radius: ${({ theme }) => theme.radii.pill};
  transition: width 0.3s ease;
`;
