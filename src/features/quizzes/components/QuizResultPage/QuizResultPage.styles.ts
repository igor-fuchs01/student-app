import styled from "styled-components";
import { Card } from "@components/ui/Card";

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

  @media (max-width: ${({ theme }) => theme.breakpoints.md}) {
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

  @media (max-width: ${({ theme }) => theme.breakpoints.sm}) {
    max-height: none;
    overflow-y: visible;
    padding: 0;
  }
`;

export const StyledReviewCard = styled(Card)`
  padding: 16px;
`;

export const StyledReviewSubject = styled.span<{ $tone: "danger" | "accent2" }>`
  color: ${({ theme, $tone }) =>
    $tone === "danger" ? theme.colors.danger600 : theme.colors.accent2600};
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

  @media (max-width: ${({ theme }) => theme.breakpoints.sm}) {
    min-height: 44px;
  }
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

export const StyledPageActions = styled.div`
  display: flex;
  justify-content: space-between;
  gap: 12px;
  flex-wrap: wrap;
  margin-top: 32px;
  padding-top: 20px;
  border-top: 1px solid ${({ theme }) => theme.colors.divider};

  @media (max-width: ${({ theme }) => theme.breakpoints.sm}) {
    flex-direction: column-reverse;
    align-items: stretch;
  }
`;
