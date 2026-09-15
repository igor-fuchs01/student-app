import styled from "styled-components";

export const StyledErrorPage = styled.main`
  min-height: 100%;
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  gap: 12px;
  padding: 24px;
  text-align: center;
  background: ${({ theme }) => theme.colors.bg};
`;

export const StyledTitle = styled.h1`
  font-family: ${({ theme }) => theme.fonts.heading};
  font-weight: 700;
  font-size: 20px;
  margin: 0;
`;

export const StyledMessage = styled.p`
  color: ${({ theme }) => theme.colors.muted};
  font-size: 14px;
  margin: 0 0 8px;
`;
