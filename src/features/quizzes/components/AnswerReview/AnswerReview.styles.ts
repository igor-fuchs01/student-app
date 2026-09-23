import styled, { css } from "styled-components";
import { Card } from "@components/ui/Card";

export type ReviewTone = "correct" | "wrong" | "self" | "neutral";

export const StyledReviewCard = styled(Card)`
  padding: 16px;
`;

export const StyledReviewQuestionHeader = styled.div`
  display: flex;
  justify-content: space-between;
  align-items: center;
  gap: 8px;
`;

export const StyledReviewSubject = styled.span`
  color: ${({ theme }) => theme.colors.muted};
  font-size: 11px;
  font-weight: 700;
  letter-spacing: 0.04em;
  text-transform: uppercase;
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

export const StyledReviewOption = styled.div<{ $tone: ReviewTone }>`
  display: flex;
  flex-wrap: wrap;
  justify-content: space-between;
  align-items: center;
  gap: 4px 12px;
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

export const StyledReviewExplanation = styled.p`
  font-size: 13px;
  margin: 8px 0 0;
  padding-top: 8px;
  border-top: 1px solid ${({ theme }) => theme.colors.divider};
`;
