import styled, { css } from "styled-components";
import { Card } from "@components/ui/Card";
import type { StudyFocusLevel } from "@models/dashboard";

export const StyledStudyFocusCard = styled(Card)`
  display: flex;
  flex-direction: column;
  gap: 16px;
  min-width: 0;
  border: 1px solid ${({ theme }) => theme.colors.divider};
  min-height: 0;
  padding: 18px 22px;
  overflow: hidden;
`;

export const StyledTitle = styled.h2`
  font-size: 15px;
  font-weight: 700;
  line-height: 1.3;
  margin: 0;
`;

export const StyledTopic = styled.div`
  display: flex;
  flex-direction: column;
  align-items: flex-start;
  gap: 2px;

  > span:first-child {
    margin-bottom: 6px;
  }
`;

export const StyledTopicName = styled.p`
  margin: 0;
  font-family: ${({ theme }) => theme.fonts.heading};
  font-size: 19px;
  font-weight: 700;
  line-height: 1.25;
`;

export const StyledTopicMeta = styled.span`
  font-size: 12.5px;
  color: ${({ theme }) => theme.colors.muted};
`;

export const StyledSectionLabel = styled.span`
  font-size: 11px;
  font-weight: 700;
  letter-spacing: 0.05em;
  text-transform: uppercase;
  color: ${({ theme }) => theme.colors.muted};
`;

export const StyledWhy = styled.div`
  display: flex;
  flex-direction: column;
  gap: 8px;
`;

export const StyledAccuracyTrack = styled.div`
  position: relative;
  height: 8px;
  border-radius: ${({ theme }) => theme.radii.pill};
  background: rgba(0, 0, 0, 0.07);
`;

export const StyledAccuracyFill = styled.div<{ $value: number; $level: StudyFocusLevel }>`
  height: 100%;
  width: ${({ $value }) => Math.min(100, Math.max(0, $value))}%;
  border-radius: inherit;
  background: ${({ theme, $level }) =>
    $level === "high"
      ? theme.colors.danger
      : $level === "medium"
        ? theme.colors.accent2
        : theme.colors.muted};
`;

export const StyledTargetMark = styled.span<{ $value: number }>`
  position: absolute;
  top: -4px;
  bottom: -4px;
  left: ${({ $value }) => $value}%;
  width: 2px;
  border-radius: 1px;
  background: ${({ theme }) => theme.colors.text};
`;

export const StyledScale = styled.div`
  display: flex;
  justify-content: space-between;
  gap: 8px;
  font-size: 12px;
  color: ${({ theme }) => theme.colors.muted};
  font-variant-numeric: tabular-nums;

  strong {
    color: ${({ theme }) => theme.colors.text};
  }
`;

export const StyledReason = styled.p`
  margin: 0;
  font-size: 12.5px;
  color: ${({ theme }) => theme.colors.muted};
`;

export const StyledNextStep = styled.div`
  flex: none;
  display: flex;
  flex-direction: column;
  align-items: flex-start;
  gap: 8px;
  padding: 14px 16px;
  border-radius: ${({ theme }) => theme.radii.md};
  background: ${({ theme }) => theme.colors.accent100};

  > button {
    margin-top: 4px;
  }
`;

export const StyledNextStepText = styled.p`
  margin: 0;
  font-size: 13.5px;
  font-weight: 600;
  line-height: 1.4;
`;

export const StyledFooter = styled.div`
  margin-top: auto;
  padding-top: 12px;
  border-top: 1px solid ${({ theme }) => theme.colors.divider};
`;

const linkText = css`
  background: none;
  border: 0;
  padding: 0;
  font: inherit;
  text-align: left;
  cursor: pointer;
`;

export const StyledLinkButton = styled.button`
  ${linkText}
  font-size: 12.5px;
  font-weight: 600;
  color: ${({ theme }) => theme.colors.accent600};

  &:hover {
    text-decoration: underline;
  }
`;

export const StyledModalTitle = styled.h2`
  margin: 0;
  font-family: ${({ theme }) => theme.fonts.heading};
  font-size: 19px;
  font-weight: 700;
`;

export const StyledModalNote = styled.p`
  margin: 0;
  font-size: 12.5px;
  color: ${({ theme }) => theme.colors.muted};
`;

export const StyledOtherList = styled.ul`
  list-style: none;
  margin: 0;
  padding: 0;
  display: flex;
  flex-direction: column;
  gap: 8px;
`;

export const StyledOtherItem = styled.button`
  ${linkText}
  width: 100%;
  display: flex;
  flex-direction: column;
  gap: 4px;
  padding: 12px 14px;
  border: 1px solid ${({ theme }) => theme.colors.divider};
  border-radius: ${({ theme }) => theme.radii.md};
  color: ${({ theme }) => theme.colors.text};

  &:hover {
    border-color: ${({ theme }) => theme.colors.accent};
  }
`;

export const StyledOtherName = styled.span`
  display: flex;
  align-items: center;
  justify-content: space-between;
  gap: 10px;
  font-size: 13.5px;
  font-weight: 600;
`;

export const StyledOtherReason = styled.span`
  font-size: 12px;
  color: ${({ theme }) => theme.colors.muted};
`;

export const StyledModalActions = styled.div`
  display: flex;
  justify-content: flex-end;
`;

export const StyledEmpty = styled.p`
  flex: 1;
  display: grid;
  place-items: center;
  margin: 0;
  text-align: center;
  color: ${({ theme }) => theme.colors.muted};
  font-size: 13px;
`;
