import styled, { css } from "styled-components";
import { Card } from "@components/ui/Card";

export const StyledPage = styled.div`
  min-height: 100%;
  background: ${({ theme }) => theme.colors.bg};
`;

export const StyledContent = styled.main`
  padding: 26px 28px 64px;
  max-width: 1280px;
  margin: 0 auto;
`;

export const StyledStateMessage = styled.div`
  color: ${({ theme }) => theme.colors.muted};
  font-size: 14px;
`;

export const StyledHeaderRow = styled.div`
  display: flex;
  justify-content: space-between;
  align-items: flex-start;
  gap: 16px;
  flex-wrap: wrap;
  margin-bottom: 22px;
`;

export const StyledTitle = styled.h1`
  font-family: ${({ theme }) => theme.fonts.heading};
  font-weight: 700;
  font-size: 18px;
  margin: 0 0 4px;
`;

export const StyledSubmittedAt = styled.p`
  color: ${({ theme }) => theme.colors.muted};
  font-size: 13px;
  margin: 0;
`;

export const StyledScoreBox = styled.div`
  text-align: right;
  background: ${({ theme }) => theme.colors.accent100};
  border-radius: ${({ theme }) => theme.radii.lg};
  padding: 14px 22px;
`;

export const StyledScoreValue = styled.div`
  font-family: ${({ theme }) => theme.fonts.heading};
  font-weight: 800;
  font-size: 34px;
  line-height: 1;
  color: ${({ theme }) => theme.colors.accent600};
`;

export const StyledScoreLabel = styled.div`
  color: ${({ theme }) => theme.colors.muted};
  font-size: 12px;
`;

export const StyledBadgeRow = styled.div`
  display: flex;
  gap: 10px;
  margin-bottom: 28px;
  flex-wrap: wrap;
`;

export const StyledColumns = styled.div`
  display: grid;
  grid-template-columns: 1fr 1fr;
  gap: 28px;

  @media (max-width: 860px) {
    grid-template-columns: 1fr;
  }
`;

export const StyledColumnTitle = styled.h2`
  font-family: ${({ theme }) => theme.fonts.heading};
  font-weight: 700;
  font-size: 15px;
  margin: 0 0 14px;
`;

export const StyledPerformanceList = styled.div`
  display: flex;
  flex-direction: column;
  gap: 16px;
`;

export const StyledPerformanceHeader = styled.div`
  display: flex;
  justify-content: space-between;
  font-size: 13px;
  margin-bottom: 5px;

  span:last-child {
    font-weight: 700;
  }
`;

export const StyledReviewList = styled.div`
  display: flex;
  flex-direction: column;
  gap: 10px;
  max-height: 440px;
  overflow-y: auto;
  padding: 4px 8px 4px 4px;
`;

export const StyledReviewCard = styled(Card)`
  padding: 16px;
`;

export const StyledReviewSubject = styled.span<{ $tone?: "danger" | "accent2" }>`
  color: ${({ theme, $tone }) =>
    $tone === "danger"
      ? theme.colors.danger600
      : $tone === "accent2"
        ? theme.colors.accent2600
        : theme.colors.muted};
  font-size: 11px;
  font-weight: 700;
  letter-spacing: 0.04em;
  text-transform: uppercase;
`;

export const StyledReviewExcerpt = styled.p`
  font-size: 13px;
  margin: 6px 0 10px;
  color: ${({ theme }) => theme.colors.muted};
`;

export const StyledReviewToggle = styled.button`
  background: transparent;
  border: none;
  color: ${({ theme }) => theme.colors.accent600};
  font: inherit;
  font-weight: 700;
  font-size: 13px;
  cursor: pointer;
  padding: 0;
`;

export const StyledReviewExplanation = styled.p`
  font-size: 13px;
  margin: 8px 0 0;
  padding-top: 8px;
  border-top: 1px solid ${({ theme }) => theme.colors.divider};
`;

export const StyledMutedLabel = styled.span`
  color: ${({ theme }) => theme.colors.muted};
  font-size: 12.5px;
  font-weight: 600;
`;

export const StyledAnswerComparison = styled.div`
  display: flex;
  flex-direction: column;
  gap: 10px;
  margin-top: 8px;
  padding-top: 8px;
  border-top: 1px solid ${({ theme }) => theme.colors.divider};
`;

export const StyledAnswerLabel = styled.div`
  font-size: 11px;
  font-weight: 700;
  text-transform: uppercase;
  letter-spacing: 0.04em;
  color: ${({ theme }) => theme.colors.muted};
  margin-bottom: 4px;
`;

export const StyledAnswerText = styled.p`
  font-size: 13px;
  margin: 0;
`;

export const StyledPageActions = styled.div`
  display: flex;
  justify-content: space-between;
  gap: 12px;
  flex-wrap: wrap;
  margin-top: 32px;
  padding-top: 20px;
  border-top: 1px solid ${({ theme }) => theme.colors.divider};
`;

export const StyledExamLayout = styled.div`
  display: flex;
  gap: 24px;
  align-items: flex-start;
  flex-wrap: wrap;
`;

export const StyledExamMain = styled.div`
  flex: 1;
  min-width: 280px;
`;

export const StyledExamSidebar = styled(Card)`
  width: 320px;
  flex: none;
  padding: 20px;
`;

export const StyledExamSidebarLabel = styled.div`
  color: ${({ theme }) => theme.colors.muted};
  font-size: 11px;
  letter-spacing: 0.05em;
  text-transform: uppercase;
  margin-bottom: 10px;
`;

export const StyledExamGrid = styled.div`
  display: grid;
  grid-template-columns: repeat(6, 1fr);
  gap: 6px;
  margin-bottom: 14px;
  max-height: 320px;
  overflow-y: auto;
  padding: 4px;
`;

type ExamStatus = "correct" | "incorrect" | "unanswered" | "self_review";

const examStatusStyles = css<{ $status: ExamStatus }>`
  ${({ theme, $status }) =>
    $status === "correct" &&
    css`
      background: ${theme.colors.accent};
      color: #fff;
    `}

  ${({ theme, $status }) =>
    $status === "incorrect" &&
    css`
      background: ${theme.colors.danger};
      color: #fff;
    `}

  ${({ theme, $status }) =>
    $status === "unanswered" &&
    css`
      background: ${theme.colors.danger100};
      color: ${theme.colors.danger600};
      border-color: ${theme.colors.danger};
      border-style: dashed;
    `}

  ${({ theme, $status }) =>
    $status === "self_review" &&
    css`
      background: ${theme.colors.accent2};
      color: #fff;
    `}
`;

export const StyledExamTile = styled.button<{ $status: ExamStatus; $current: boolean }>`
  height: 32px;
  box-sizing: border-box;
  border-radius: ${({ theme }) => theme.radii.md};
  border: 2px solid transparent;
  font-family: inherit;
  font-size: 12px;
  font-weight: 700;
  cursor: pointer;
  ${examStatusStyles}

  ${({ theme, $current }) =>
    $current &&
    css`
      box-shadow: 0 0 0 2px ${theme.colors.text};
    `}
`;

export const StyledExamLegend = styled.div`
  display: flex;
  flex-direction: column;
  gap: 6px;
  font-size: 11px;
  color: ${({ theme }) => theme.colors.muted};
`;

export const StyledExamLegendItem = styled.div`
  display: flex;
  align-items: center;
  gap: 6px;
`;

export const StyledExamLegendDot = styled.span<{ $status: ExamStatus }>`
  width: 10px;
  height: 10px;
  box-sizing: border-box;
  border-radius: 4px;
  border: 2px solid transparent;
  ${examStatusStyles}
`;

export const StyledReviewQuestionHeader = styled.div`
  display: flex;
  justify-content: space-between;
  align-items: center;
  gap: 8px;
`;

export const StyledReviewPrompt = styled.p`
  font-size: 13.5px;
  font-weight: 600;
  margin: 8px 0 10px;
`;

export const StyledReviewOptionList = styled.div`
  display: flex;
  flex-direction: column;
  gap: 8px;
`;

export type ReviewTone = "correct" | "wrong" | "self" | "neutral";

export const StyledReviewOption = styled.div<{ $tone: ReviewTone }>`
  display: flex;
  justify-content: space-between;
  align-items: center;
  gap: 12px;
  padding: 10px 14px;
  border-radius: ${({ theme }) => theme.radii.md};
  font-size: 13px;

  ${({ theme, $tone }) =>
    $tone === "correct" &&
    css`
      border: 1.5px solid ${theme.colors.accent};
      background: ${theme.colors.accent100};
    `}

  ${({ theme, $tone }) =>
    $tone === "wrong" &&
    css`
      border: 1.5px solid ${theme.colors.danger};
      background: ${theme.colors.danger100};
    `}

  ${({ theme, $tone }) =>
    $tone === "neutral" &&
    css`
      border: 1.5px solid ${theme.colors.divider};
    `}
`;

export const StyledReviewOptionTag = styled.span`
  font-size: 11.5px;
  font-weight: 700;
  white-space: nowrap;
`;

export const StyledReviewSentence = styled.div`
  font-size: 14px;
  line-height: 2.2;
  margin: 8px 0 4px;
`;

export const StyledReviewBlank = styled.span<{ $tone: ReviewTone }>`
  display: inline-block;
  padding: 0 10px;
  margin: 0 3px;
  border-radius: ${({ theme }) => theme.radii.md};
  font-size: 13px;
  font-weight: 700;
  line-height: 1.9;

  ${({ theme, $tone }) =>
    $tone === "correct" &&
    css`
      background: ${theme.colors.accent100};
      color: ${theme.colors.accent600};
    `}

  ${({ theme, $tone }) =>
    $tone === "wrong" &&
    css`
      background: ${theme.colors.danger100};
      color: ${theme.colors.danger600};
      text-decoration: line-through;
    `}

  ${({ theme, $tone }) =>
    $tone === "self" &&
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
