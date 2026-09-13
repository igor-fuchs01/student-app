import styled, { css } from "styled-components";

export type BadgeTone = "accent" | "accent2" | "neutral";

export const StyledBadge = styled.span<{ $tone: BadgeTone }>`
  display: inline-flex;
  align-items: center;
  gap: 6px;
  font-size: 11px;
  font-weight: 700;
  padding: 4px 12px;
  border-radius: ${({ theme }) => theme.radii.pill};
  white-space: nowrap;

  ${({ theme, $tone }) =>
    $tone === "accent" &&
    css`
      background: ${theme.colors.accent100};
      color: ${theme.colors.accent600};
    `}

  ${({ theme, $tone }) =>
    $tone === "accent2" &&
    css`
      background: ${theme.colors.accent2100};
      color: ${theme.colors.accent2600};
    `}

  ${({ theme, $tone }) =>
    $tone === "neutral" &&
    css`
      background: rgba(0, 0, 0, 0.06);
      color: ${theme.colors.muted};
    `}
`;
