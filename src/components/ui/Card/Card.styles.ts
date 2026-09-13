import styled, { css } from "styled-components";

export type CardTone = "surface" | "surface2" | "accent";

export const StyledCard = styled.div<{ $tone: CardTone }>`
  border-radius: ${({ theme }) => theme.radii.lg};
  padding: 22px;
  box-shadow: ${({ theme }) => theme.shadows.sm};

  ${({ theme, $tone }) =>
    $tone === "surface" &&
    css`
      background: ${theme.colors.surface};
    `}

  ${({ theme, $tone }) =>
    $tone === "surface2" &&
    css`
      background: ${theme.colors.surface2};
    `}

  ${({ theme, $tone }) =>
    $tone === "accent" &&
    css`
      background: ${theme.colors.accent};
      color: #fff;
      box-shadow: ${theme.shadows.md};
    `}
`;
