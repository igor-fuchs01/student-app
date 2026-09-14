import styled from "styled-components";

export const StyledStatusMessage = styled.div`
  color: ${({ theme }) => theme.colors.muted};
  font-size: 14px;

  p {
    margin: 0 0 12px;
  }
`;
