import styled from "styled-components";

export const StyledForm = styled.form`
  display: flex;
  flex-direction: column;
  max-height: calc(100vh - 80px);
  max-height: calc(100dvh - 80px);
`;

export const StyledTitle = styled.h2`
  font-weight: 700;
  font-size: 17px;
  margin: 0 0 16px;
`;

export const StyledFields = styled.div`
  overflow-y: auto;
  padding: 2px;
`;

export const StyledActions = styled.div`
  display: flex;
  justify-content: flex-end;
  gap: 10px;
  margin-top: 16px;

  @media (max-width: ${({ theme }) => theme.breakpoints.sm}) {
    flex-direction: column-reverse;
  }
`;
