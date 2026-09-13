import styled, { css } from "styled-components";

export type ButtonVariant = "primary" | "secondary" | "ghost";

export const StyledButton = styled.button<{ $variant: ButtonVariant }>`
  min-height: 46px;
  padding: 10px 22px;
  border-radius: ${({ theme }) => theme.radii.pill};
  font-weight: 700;
  font-size: 14px;
  border: none;
  transition: background-color 0.15s ease;

  &:disabled {
    opacity: 0.6;
    cursor: not-allowed;
  }

  ${({ theme, $variant }) =>
    $variant === "primary" &&
    css`
      background: ${theme.colors.accent};
      color: #fff;
      box-shadow: ${theme.shadows.sm};

      &:hover:not(:disabled) {
        background: ${theme.colors.accent600};
      }
    `}

  ${({ theme, $variant }) =>
    $variant === "secondary" &&
    css`
      background: transparent;
      color: ${theme.colors.text};
      border: 1.5px solid ${theme.colors.divider};

      &:hover:not(:disabled) {
        border-color: ${theme.colors.accent};
        color: ${theme.colors.accent600};
      }
    `}

  ${({ theme, $variant }) =>
    $variant === "ghost" &&
    css`
      background: ${theme.colors.accent2100};
      color: ${theme.colors.accent2600};
    `}
`;
