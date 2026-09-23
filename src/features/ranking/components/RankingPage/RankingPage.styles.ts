import styled, { css } from "styled-components";
import { Card } from "@components/ui/Card";

export const StyledLayout = styled.div`
  display: grid;
  grid-template-columns: 320px 1fr;
  gap: 26px;
  align-items: start;

  @media (max-width: ${({ theme }) => theme.breakpoints.md}) {
    grid-template-columns: 1fr;
  }
`;

export const StyledProfileCard = styled(Card)`
  padding: 22px;
`;

export const StyledAvatar = styled.div`
  width: 58px;
  height: 58px;
  border-radius: ${({ theme }) => theme.radii.pill};
  background: ${({ theme }) => theme.colors.accent};
  color: #fff;
  display: flex;
  align-items: center;
  justify-content: center;
  font-family: ${({ theme }) => theme.fonts.heading};
  font-weight: 700;
  font-size: 18px;
  margin-bottom: 12px;
`;

export const StyledProfileName = styled.div`
  font-family: ${({ theme }) => theme.fonts.heading};
  font-weight: 700;
  font-size: 16px;
`;

export const StyledProfileCourse = styled.div`
  color: ${({ theme }) => theme.colors.muted};
  font-size: 12.5px;
  margin-bottom: 16px;
`;

export const StyledDivider = styled.div`
  height: 1px;
  background: ${({ theme }) => theme.colors.divider};
  margin-bottom: 16px;
`;

export const StyledMutedLabel = styled.div`
  color: ${({ theme }) => theme.colors.muted};
  font-size: 12px;
  margin-bottom: 5px;
`;

export const StyledStreak = styled.div`
  font-family: ${({ theme }) => theme.fonts.heading};
  font-weight: 800;
  font-size: 24px;
  color: ${({ theme }) => theme.colors.accent600};
  margin-bottom: 14px;
`;

export const StyledStatsGrid = styled.div`
  display: grid;
  grid-template-columns: 1fr 1fr;
  gap: 10px;
  margin-top: 16px;
  text-align: center;
`;

export const StyledStat = styled.div<{ $tone: "accent" | "accent2" }>`
  border-radius: ${({ theme }) => theme.radii.md};
  padding: 10px;
  background: ${({ theme, $tone }) =>
    $tone === "accent" ? theme.colors.accent100 : theme.colors.accent2100};
`;

export const StyledStatValue = styled.div<{ $tone: "accent" | "accent2" }>`
  font-family: ${({ theme }) => theme.fonts.heading};
  font-weight: 800;
  font-size: 17px;
  color: ${({ theme, $tone }) =>
    $tone === "accent" ? theme.colors.accent600 : theme.colors.accent2600};
`;

export const StyledStatLabel = styled.div`
  color: ${({ theme }) => theme.colors.muted};
  font-size: 11px;
`;

export const StyledRankingTitle = styled.h1`
  font-family: ${({ theme }) => theme.fonts.heading};
  font-weight: 700;
  font-size: 16px;
  margin: 0 0 14px;
`;

export const StyledRankingList = styled(Card)`
  padding: 0;
  overflow: hidden;
`;

export const StyledRankingRow = styled.div<{ $current: boolean }>`
  display: flex;
  align-items: center;
  justify-content: space-between;
  gap: 12px;
  padding: 14px 18px;
  font-size: 14px;

  & + & {
    border-top: 1px solid ${({ theme }) => theme.colors.divider};
  }

  ${({ theme, $current }) =>
    $current &&
    css`
      background: ${theme.colors.accent100};
      font-weight: 700;
    `}
`;

export const StyledPosition = styled.strong`
  font-family: ${({ theme }) => theme.fonts.heading};
  margin-right: 4px;
`;

export const StyledYouBadge = styled.span`
  background: ${({ theme }) => theme.colors.accent};
  color: #fff;
  font-size: 10.5px;
  font-weight: 700;
  padding: 3px 10px;
  border-radius: ${({ theme }) => theme.radii.pill};
  margin-left: 6px;
`;

export const StyledStreakDays = styled.span<{ $current: boolean }>`
  font-size: 13px;
  white-space: nowrap;
  color: ${({ theme, $current }) => ($current ? theme.colors.accent600 : theme.colors.muted)};
`;

export const StyledPrivacyNote = styled.p`
  color: ${({ theme }) => theme.colors.muted};
  font-size: 12px;
  line-height: 1.5;
  margin: 14px 0 0;
`;
