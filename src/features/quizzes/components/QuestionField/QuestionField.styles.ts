import styled, { css } from "styled-components";
import { Badge } from "@components/ui/Badge";

const TOUCH_SCREEN = "(hover: none) and (pointer: coarse)";

const mobileInputFont = css`
  @media (max-width: ${({ theme }) => theme.breakpoints.sm}) {
    font-size: 16px;
  }
`;

export const StyledSubjectTag = styled(Badge)`
  margin-bottom: 16px;
`;

export const StyledPrompt = styled.h2`
  font-family: ${({ theme }) => theme.fonts.heading};
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

  @media (max-width: ${({ theme }) => theme.breakpoints.sm}) {
    line-height: 2.8;
  }
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

  @media (max-width: ${({ theme }) => theme.breakpoints.sm}) {
    min-height: 44px;
    padding: 8px 16px;
    font-size: 14px;
  }

  ${({ theme, $selected }) =>
    $selected &&
    css`
      outline: 2px solid ${theme.colors.accent};
      outline-offset: 2px;
    `}
`;

export const StyledSlot = styled.button<{ $filled?: boolean; $awaiting?: boolean }>`
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

  @media (max-width: ${({ theme }) => theme.breakpoints.sm}) {
    min-height: 44px;
    vertical-align: middle;
  }

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

  ${({ theme, $awaiting }) =>
    $awaiting &&
    css`
      border-color: ${theme.colors.accent};
      color: ${theme.colors.accent600};
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
  overflow-wrap: anywhere;
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

  ${mobileInputFont}

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

export const StyledPointerHint = styled.span`
  @media ${TOUCH_SCREEN} {
    display: none;
  }
`;

export const StyledTouchHint = styled.span`
  display: none;

  @media ${TOUCH_SCREEN} {
    display: inline;
  }
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

  @media (max-width: ${({ theme }) => theme.breakpoints.sm}) {
    min-height: 44px;
    max-width: 100%;
    font-size: 16px;
  }

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

  ${mobileInputFont}
`;

export const StyledCharCount = styled.span`
  display: block;
  color: ${({ theme }) => theme.colors.muted};
  font-size: 11.5px;
  margin-top: 8px;
`;
