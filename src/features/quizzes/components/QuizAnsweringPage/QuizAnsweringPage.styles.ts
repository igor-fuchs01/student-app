import styled, { css } from "styled-components";
import { Card } from "@components/ui/Card";

export const StyledContent = styled.main`
  padding: 26px 28px 64px;
  max-width: 1280px;
  margin: 0 auto;
`;

export const StyledTopBar = styled.div`
  display: flex;
  align-items: center;
  justify-content: space-between;
  flex-wrap: wrap;
  gap: 12px;
  margin-bottom: 20px;
`;

export const StyledTopBarTitle = styled.h1`
  font-family: ${({ theme }) => theme.fonts.heading};
  font-weight: 700;
  font-size: 16px;
  margin: 0;
`;

export const StyledTopBarMeta = styled.div`
  display: flex;
  align-items: center;
  gap: 18px;
`;

export const StyledQuestionCount = styled.span`
  color: ${({ theme }) => theme.colors.muted};
  font-size: 12.5px;
  font-weight: 600;
`;

export const StyledTimer = styled.span`
  display: inline-flex;
  align-items: center;
  gap: 6px;
  font-weight: 700;
  font-size: 13px;
  background: ${({ theme }) => theme.colors.accent2100};
  color: ${({ theme }) => theme.colors.accent2600};
  padding: 6px 12px;
  border-radius: ${({ theme }) => theme.radii.pill};
`;

export const StyledTimerToggle = styled.button`
  display: inline-flex;
  align-items: center;
  justify-content: center;
  flex: none;
  width: 30px;
  height: 30px;
  box-sizing: border-box;
  border-radius: ${({ theme }) => theme.radii.pill};
  border: 1.5px solid ${({ theme }) => theme.colors.divider};
  background: transparent;
  font-size: 14px;
  line-height: 1;
  cursor: pointer;

  &:hover {
    border-color: ${({ theme }) => theme.colors.accent};
  }
`;

export const StyledLayout = styled.div`
  display: flex;
  gap: 24px;
  align-items: flex-start;
  flex-wrap: wrap;
`;

export const StyledQuestionCard = styled(Card)`
  flex: 1;
  min-width: 280px;
  padding: 28px 32px;
`;

export const StyledSidebar = styled(Card)`
  width: 320px;
  flex: none;
  padding: 20px;
`;

export const StyledSidebarHeader = styled.div`
  display: flex;
  align-items: center;
  justify-content: space-between;
  gap: 8px;
  margin-bottom: 10px;
`;

export const StyledSidebarLabel = styled.div`
  color: ${({ theme }) => theme.colors.muted};
  font-size: 11px;
  letter-spacing: 0.05em;
  text-transform: uppercase;
`;

export const StyledMarkCurrentButton = styled.button<{ $marked: boolean }>`
  display: inline-flex;
  align-items: center;
  justify-content: center;
  width: 26px;
  height: 26px;
  flex: none;
  border-radius: ${({ theme }) => theme.radii.pill};
  border: 1.5px solid
    ${({ theme, $marked }) => ($marked ? theme.colors.accent2 : theme.colors.divider)};
  background: ${({ theme, $marked }) => ($marked ? theme.colors.accent2100 : "transparent")};
  font-size: 13px;
  line-height: 1;
  cursor: pointer;
`;

export const StyledQuestionGrid = styled.div`
  display: grid;
  grid-template-columns: repeat(6, 1fr);
  gap: 6px;
  margin-bottom: 14px;
  max-height: 320px;
  overflow-y: auto;
  padding: 4px;
`;

export const StyledQuestionTile = styled.button<{
  $answered: boolean;
  $marked: boolean;
  $current: boolean;
}>`
  height: 32px;
  box-sizing: border-box;
  border-radius: ${({ theme }) => theme.radii.md};
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: 12px;
  font-weight: 700;
  border: 2px solid transparent;
  cursor: pointer;
  font-family: inherit;
  background: ${({ theme, $answered }) => ($answered ? theme.colors.accent : "rgba(0, 0, 0, 0.05)")};
  color: ${({ theme, $answered }) => ($answered ? "#fff" : theme.colors.muted)};

  ${({ theme, $current }) =>
    $current &&
    css`
      border-color: ${theme.colors.accent600};
    `}

  ${({ theme, $marked }) =>
    $marked &&
    css`
      box-shadow: 0 0 0 2px ${theme.colors.accent2};
    `}
`;

export const StyledLegend = styled.div`
  display: flex;
  flex-direction: column;
  gap: 6px;
  font-size: 11px;
  color: ${({ theme }) => theme.colors.muted};
`;

export const StyledLegendItem = styled.div`
  display: flex;
  align-items: center;
  gap: 6px;
`;

type LegendTone = "answered" | "current" | "marked" | "empty";

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
    $tone === "current" &&
    css`
      background: transparent;
      border: 2px solid ${theme.colors.accent600};
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
  margin-top: 24px;
  flex-wrap: wrap;
`;
