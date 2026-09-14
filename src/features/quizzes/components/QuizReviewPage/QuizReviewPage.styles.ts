import styled, { css } from "styled-components";

export const StyledContent = styled.main`
  padding: 26px 28px 64px;
  max-width: 1280px;
  margin: 0 auto;
`;

export const StyledTitle = styled.h1`
  font-family: ${({ theme }) => theme.fonts.heading};
  font-weight: 700;
  font-size: 20px;
  margin: 0 0 4px;
`;

export const StyledSubtitle = styled.p`
  color: ${({ theme }) => theme.colors.muted};
  font-size: 13px;
  margin: 0 0 20px;
`;

export const StyledCountRow = styled.div`
  display: flex;
  gap: 10px;
  margin-bottom: 24px;
  flex-wrap: wrap;
`;

export const StyledCountBadge = styled.span<{ $tone: "neutral" | "accent" | "danger" }>`
  font-size: 11.5px;
  font-weight: 700;
  padding: 5px 14px;
  border-radius: ${({ theme }) => theme.radii.pill};

  ${({ theme, $tone }) =>
    $tone === "neutral" &&
    css`
      background: rgba(0, 0, 0, 0.06);
      color: ${theme.colors.muted};
    `}

  ${({ theme, $tone }) =>
    $tone === "accent" &&
    css`
      background: ${theme.colors.accent100};
      color: ${theme.colors.accent600};
    `}

  ${({ theme, $tone }) =>
    $tone === "danger" &&
    css`
      background: ${theme.colors.danger100};
      color: ${theme.colors.danger600};
    `}
`;

export const StyledGrid = styled.div`
  display: grid;
  grid-template-columns: repeat(10, 1fr);
  gap: 6px;
  max-width: 620px;
  margin-bottom: 16px;

  @media (max-width: 640px) {
    grid-template-columns: repeat(5, 1fr);
  }
`;

export const StyledTile = styled.button<{ $answered: boolean; $marked: boolean }>`
  height: 36px;
  box-sizing: border-box;
  border-radius: ${({ theme }) => theme.radii.md};
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: 12px;
  font-weight: 700;
  border: none;
  cursor: pointer;
  font-family: inherit;
  background: ${({ theme, $answered }) => ($answered ? theme.colors.accent : "rgba(0, 0, 0, 0.05)")};
  color: ${({ theme, $answered }) => ($answered ? "#fff" : theme.colors.muted)};

  ${({ theme, $marked }) =>
    $marked &&
    css`
      box-shadow: 0 0 0 2px ${theme.colors.accent2};
    `}
`;

export const StyledLegend = styled.div`
  display: flex;
  gap: 16px;
  font-size: 11px;
  color: ${({ theme }) => theme.colors.muted};
  flex-wrap: wrap;
  margin-bottom: 28px;
`;

export const StyledLegendItem = styled.div`
  display: flex;
  align-items: center;
  gap: 6px;
`;

type LegendTone = "answered" | "marked" | "empty";

export const StyledLegendDot = styled.span<{ $tone: LegendTone }>`
  width: 10px;
  height: 10px;
  border-radius: 4px;
  box-sizing: border-box;

  ${({ theme, $tone }) =>
    $tone === "answered" &&
    css`
      background: ${theme.colors.accent};
    `}

  ${({ theme, $tone }) =>
    $tone === "marked" &&
    css`
      background: rgba(0, 0, 0, 0.05);
      box-shadow: 0 0 0 2px ${theme.colors.accent2};
    `}

  ${({ $tone }) =>
    $tone === "empty" &&
    css`
      background: rgba(0, 0, 0, 0.05);
    `}
`;

export const StyledFooter = styled.div`
  display: flex;
  justify-content: space-between;
  align-items: center;
  gap: 12px;
  flex-wrap: wrap;
`;

export const StyledConfirmTitle = styled.div`
  font-family: ${({ theme }) => theme.fonts.heading};
  font-weight: 700;
  font-size: 19px;
`;

export const StyledConfirmBody = styled.div`
  font-size: 13.5px;
  color: ${({ theme }) => theme.colors.muted};
  line-height: 1.5;

  strong {
    color: ${({ theme }) => theme.colors.text};
  }
`;

export const StyledConfirmActions = styled.div`
  display: flex;
  justify-content: flex-end;
  gap: 10px;
  margin-top: 6px;
`;

export const StyledErrorMessage = styled.p`
  color: ${({ theme }) => theme.colors.accent2600};
  font-size: 12.5px;
  margin: 0;
`;
