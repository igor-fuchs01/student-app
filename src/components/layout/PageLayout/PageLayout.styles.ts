import styled, { css, type DefaultTheme } from "styled-components";

const fitViewportMedia = ({ theme }: { theme: DefaultTheme }) =>
  `(min-width: ${theme.breakpoints.md}) and (min-height: 560px)`;

export const StyledPage = styled.div<{ $fitViewport: boolean }>`
  min-height: 100%;
  background: ${({ theme }) => theme.colors.bg};

  ${({ $fitViewport }) =>
    $fitViewport &&
    css`
      @media ${fitViewportMedia} {
        height: 100%;
        display: flex;
        flex-direction: column;
        overflow: hidden;
      }
    `}
`;

export const StyledContent = styled.main<{ $fitViewport: boolean }>`
  padding: 26px max(28px, env(safe-area-inset-right)) 64px max(28px, env(safe-area-inset-left));
  max-width: 1280px;
  margin: 0 auto;

  @media (max-width: ${({ theme }) => theme.breakpoints.sm}) {
    padding: 18px 16px calc(96px + env(safe-area-inset-bottom));
  }

  ${({ $fitViewport }) =>
    $fitViewport &&
    css`
      @media ${fitViewportMedia} {
        flex: 1;
        min-height: 0;
        width: 100%;
        display: flex;
        flex-direction: column;
        padding-top: 20px;
        padding-bottom: 22px;
      }
    `}
`;
