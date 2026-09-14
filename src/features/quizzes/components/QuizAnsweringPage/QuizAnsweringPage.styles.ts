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
  font-family: "Poppins", sans-serif;
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

export const StyledSubjectTag = styled.span`
  display: inline-block;
  background: rgba(0, 0, 0, 0.06);
  color: ${({ theme }) => theme.colors.muted};
  font-size: 11px;
  font-weight: 700;
  padding: 4px 12px;
  border-radius: ${({ theme }) => theme.radii.pill};
  margin-bottom: 16px;
`;

export const StyledPrompt = styled.h2`
  font-family: "Poppins", sans-serif;
  font-weight: 700;
  font-size: 17px;
  line-height: 1.35;
  margin: 0 0 20px;
  max-width: 560px;
`;

export const StyledOptionList = styled.div`
  display: flex;
  flex-direction: column;
  gap: 10px;
  max-width: 560px;
`;

export const StyledOptionLabel = styled.label<{ $selected?: boolean }>`
  display: flex;
  align-items: center;
  gap: 12px;
  padding: 12px 16px;
  border-radius: ${({ theme }) => theme.radii.md};
  font-size: 13.5px;
  cursor: pointer;

  ${({ theme, $selected }) =>
    $selected
      ? css`
          border: 1.5px solid ${theme.colors.accent};
          background: ${theme.colors.accent100};
          font-weight: 600;
        `
      : css`
          border: 1.5px solid ${theme.colors.divider};
        `}

  input {
    width: 16px;
    height: 16px;
    accent-color: ${({ theme }) => theme.colors.accent};
  }
`;

export const StyledDropdownSentence = styled.div`
  font-size: 14.5px;
  line-height: 2.1;
  font-weight: 500;
  max-width: 560px;
`;

export const StyledTermBank = styled.div`
  display: flex;
  flex-wrap: wrap;
  gap: 8px;
  margin-top: 18px;
  padding-top: 16px;
  border-top: 1px solid ${({ theme }) => theme.colors.divider};
`;

export const StyledTermBankLabel = styled.div`
  width: 100%;
  color: ${({ theme }) => theme.colors.muted};
  font-size: 11px;
  font-weight: 600;
  margin-bottom: 4px;
`;

export const StyledTermChip = styled.button<{ $used?: boolean; $selected?: boolean }>`
  display: inline-flex;
  align-items: center;
  gap: 6px;
  padding: 6px 12px;
  border-radius: ${({ theme }) => theme.radii.pill};
  background: ${({ theme }) => theme.colors.accent2100};
  color: ${({ theme }) => theme.colors.accent2600};
  font: inherit;
  font-size: 12.5px;
  font-weight: 700;
  border: none;
  cursor: grab;
  opacity: ${({ $used }) => ($used ? 0.45 : 1)};

  ${({ theme, $selected }) =>
    $selected &&
    css`
      outline: 2px solid ${theme.colors.accent};
      outline-offset: 2px;
    `}
`;

export const StyledSlot = styled.button<{ $filled?: boolean }>`
  display: inline-flex;
  align-items: center;
  justify-content: center;
  min-width: 110px;
  padding: 5px 10px;
  border-radius: ${({ theme }) => theme.radii.md};
  font: inherit;
  font-size: 13px;
  font-weight: 700;
  margin: 0 2px;
  cursor: pointer;

  ${({ theme, $filled }) =>
    $filled
      ? css`
          background: ${theme.colors.accent100};
          border: 1.5px solid ${theme.colors.accent};
          color: ${theme.colors.accent600};
        `
      : css`
          background: ${theme.colors.bg};
          border: 1.5px dashed ${theme.colors.divider};
          color: ${theme.colors.muted};
        `}
`;

export const StyledCodeSentence = styled.div`
  font-family: "Consolas", "Courier New", monospace;
  font-size: 14.5px;
  line-height: 2.3;
  max-width: 560px;
  padding: 10px 14px;
  border-radius: ${({ theme }) => theme.radii.md};
  border: 1px solid ${({ theme }) => theme.colors.divider};
  background: ${({ theme }) => theme.colors.bg};
`;

export const StyledBlankInput = styled.input<{ $answered?: boolean }>`
  width: 110px;
  padding: 4px 8px;
  margin: 0 4px;
  border-radius: ${({ theme }) => theme.radii.md};
  font: inherit;
  font-weight: 700;
  font-size: 13px;
  text-align: center;

  ${({ theme, $answered }) =>
    $answered
      ? css`
          border: 1.5px solid ${theme.colors.accent};
          background: ${theme.colors.accent100};
          color: ${theme.colors.accent600};
        `
      : css`
          border: 1.5px dashed ${theme.colors.divider};
          background: ${theme.colors.surface};
          color: ${theme.colors.text};
        `}
`;

export const StyledDragHandle = styled.span`
  letter-spacing: -2px;
`;

export const StyledDragDropHint = styled.p`
  color: ${({ theme }) => theme.colors.muted};
  font-size: 11.5px;
  margin: 10px 0 0;
`;

export const StyledDropdown = styled.select<{ $answered?: boolean }>`
  display: inline-block;
  min-width: 140px;
  padding: 5px 8px;
  border-radius: ${({ theme }) => theme.radii.md};
  font: inherit;
  font-weight: 700;
  font-size: 13px;
  margin: 0 4px;

  ${({ theme, $answered }) =>
    $answered
      ? css`
          border: 1.5px solid ${theme.colors.accent};
          background: ${theme.colors.accent100};
          color: ${theme.colors.accent600};
        `
      : css`
          border: 1.5px dashed ${theme.colors.divider};
          background: ${theme.colors.bg};
          color: ${theme.colors.muted};
        `}
`;

export const StyledTextarea = styled.textarea`
  width: 100%;
  min-height: 140px;
  max-width: 560px;
  padding: 12px 14px;
  border-radius: ${({ theme }) => theme.radii.md};
  border: 1.5px solid ${({ theme }) => theme.colors.divider};
  background: ${({ theme }) => theme.colors.bg};
  font: inherit;
  font-size: 13.5px;
  box-sizing: border-box;
  resize: vertical;
  display: block;
`;

export const StyledCharCount = styled.span`
  display: block;
  color: ${({ theme }) => theme.colors.muted};
  font-size: 11.5px;
  margin-top: 8px;
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
