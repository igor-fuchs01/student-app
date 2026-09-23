import styled from "styled-components";

export const StyledPage = styled.div`
  min-height: 100%;
  background: ${({ theme }) => theme.colors.bg};
`;

export const StyledContent = styled.main`
  padding: 26px max(28px, env(safe-area-inset-right)) 64px max(28px, env(safe-area-inset-left));
  max-width: 1280px;
  margin: 0 auto;

  @media (max-width: ${({ theme }) => theme.breakpoints.sm}) {
    padding: 18px 16px calc(96px + env(safe-area-inset-bottom));
  }
`;
