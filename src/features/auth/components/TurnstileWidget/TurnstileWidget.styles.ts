import styled from "styled-components";

export const StyledWidget = styled.div`
  min-height: 65px;
  margin-top: 4px;
`;

export const StyledLoadError = styled.p`
  margin: 0;
  font-size: 12.5px;
  color: ${({ theme }) => theme.colors.danger600};
`;
