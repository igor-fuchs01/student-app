import styled, { css } from "styled-components";

export type QuestionGridVariant = "compact" | "wide";

export type QuestionTileTone =
  "answered" | "empty" | "correct" | "incorrect" | "unanswered" | "self_review";

type TileStateProps = {
  $tone?: QuestionTileTone;
  $marked: boolean;
  $current: boolean;
};

const tileStateStyles = css<TileStateProps>`
  ${({ theme, $tone }) =>
    ($tone === "answered" || $tone === "correct") &&
    css`
      background: ${theme.colors.accent};
      color: #fff;
    `}

  ${({ theme, $tone }) =>
    $tone === "empty" &&
    css`
      background: rgba(0, 0, 0, 0.05);
      color: ${theme.colors.muted};
    `}

  ${({ theme, $tone }) =>
    $tone === "incorrect" &&
    css`
      background: ${theme.colors.danger};
      color: #fff;
    `}

  ${({ theme, $tone }) =>
    $tone === "unanswered" &&
    css`
      background: ${theme.colors.danger100};
      color: ${theme.colors.danger600};
      border-color: ${theme.colors.danger};
      border-style: dashed;
    `}

  ${({ theme, $tone }) =>
    $tone === "self_review" &&
    css`
      background: ${theme.colors.accent2};
      color: #fff;
    `}

  ${({ theme, $marked }) =>
    $marked &&
    css`
      box-shadow: 0 0 0 2px ${theme.colors.accent2};
    `}
`;

export const StyledGrid = styled.div<{ $variant: QuestionGridVariant }>`
  display: grid;
  gap: 6px;
  padding: 4px;

  ${({ $variant }) =>
    $variant === "compact"
      ? css`
          grid-template-columns: repeat(6, 1fr);
          max-height: 320px;
          overflow-y: auto;
          margin-bottom: 14px;
        `
      : css`
          grid-template-columns: repeat(10, 1fr);
          max-width: 620px;
          margin-bottom: 16px;

          @media (max-width: 640px) {
            grid-template-columns: repeat(5, 1fr);
          }
        `}
`;

export const StyledTile = styled.button<TileStateProps & { $variant: QuestionGridVariant }>`
  height: ${({ $variant }) => ($variant === "compact" ? "32px" : "36px")};
  display: flex;
  align-items: center;
  justify-content: center;
  border-radius: ${({ theme }) => theme.radii.md};
  border: 2px solid transparent;
  font-family: inherit;
  font-size: 12px;
  font-weight: 700;
  cursor: pointer;

  &:disabled {
    cursor: default;
  }

  ${tileStateStyles}

  ${({ theme, $current }) =>
    $current &&
    css`
      outline: 2px solid ${theme.colors.accent600};
      outline-offset: 2px;
    `}
`;

export const StyledLegend = styled.div<{ $variant: QuestionGridVariant }>`
  display: flex;
  font-size: 11px;
  color: ${({ theme }) => theme.colors.muted};

  ${({ $variant }) =>
    $variant === "compact"
      ? css`
          flex-direction: column;
          gap: 6px;
        `
      : css`
          flex-wrap: wrap;
          gap: 16px;
          margin-bottom: 28px;
        `}
`;

export const StyledLegendItem = styled.div`
  display: flex;
  align-items: center;
  gap: 6px;
`;

export const StyledLegendDot = styled.span<TileStateProps>`
  width: 10px;
  height: 10px;
  border-radius: 4px;
  border: 2px solid transparent;

  ${tileStateStyles}

  ${({ theme, $current }) =>
    $current &&
    css`
      border-color: ${theme.colors.accent600};
    `}
`;
