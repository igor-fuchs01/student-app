import styled, { css } from "styled-components";
import { Card } from "@components/ui/Card";

export const StyledCalendarCard = styled(Card)`
  padding: 20px;
`;

export const StyledHeader = styled.div`
  display: flex;
  align-items: center;
  justify-content: space-between;
  gap: 8px;
  margin-bottom: 14px;
`;

export const StyledTitle = styled.h2`
  font-family: ${({ theme }) => theme.fonts.heading};
  font-weight: 700;
  font-size: 15px;
  margin: 0;
`;

export const StyledMonthNav = styled.div`
  display: flex;
  align-items: center;
  gap: 4px;
`;

export const StyledMonthLabel = styled.span`
  min-width: 112px;
  text-align: center;
  font-size: 12.5px;
  font-weight: 700;
`;

export const StyledNavButton = styled.button`
  width: 28px;
  height: 28px;
  border-radius: ${({ theme }) => theme.radii.pill};
  border: 1px solid ${({ theme }) => theme.colors.divider};
  background: transparent;
  color: ${({ theme }) => theme.colors.text};
  font-size: 14px;
  line-height: 1;
  cursor: pointer;

  &:hover:not(:disabled) {
    border-color: ${({ theme }) => theme.colors.accent};
    color: ${({ theme }) => theme.colors.accent600};
  }

  &:disabled {
    opacity: 0.35;
    cursor: not-allowed;
  }
`;

export const StyledWeekdays = styled.div`
  display: grid;
  grid-template-columns: repeat(7, 1fr);
  gap: 4px;
  margin-bottom: 4px;
  color: ${({ theme }) => theme.colors.muted};
  font-size: 11px;
  font-weight: 700;
  text-align: center;
`;

export const StyledDays = styled.ol<{ $loading: boolean }>`
  display: grid;
  grid-template-columns: repeat(7, 1fr);
  gap: 4px;
  list-style: none;
  margin: 0;
  padding: 0;
  opacity: ${({ $loading }) => ($loading ? 0.5 : 1)};
  transition: opacity 0.15s ease;
`;

export const StyledBlankDay = styled.li`
  aspect-ratio: 1;
`;

export const StyledDay = styled.li<{ $active: boolean; $today: boolean; $future: boolean }>`
  aspect-ratio: 1;
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  gap: 3px;
  border-radius: 10px;
  font-size: 12px;
  font-weight: 600;
  color: ${({ theme }) => theme.colors.muted};

  ${({ theme, $active }) =>
    $active &&
    css`
      background: ${theme.colors.accent100};
      color: ${theme.colors.accent600};
      font-weight: 800;
    `}

  ${({ theme, $today }) =>
    $today &&
    css`
      box-shadow: inset 0 0 0 1.5px ${theme.colors.accent};
    `}

  ${({ $future }) =>
    $future &&
    css`
      opacity: 0.4;
    `}
`;

export const StyledMarkers = styled.span`
  display: flex;
  gap: 3px;
  height: 5px;
`;

export const StyledMarker = styled.span<{ $kind: "exam" | "exercise" }>`
  width: 5px;
  height: 5px;
  border-radius: ${({ theme }) => theme.radii.pill};
  background: ${({ theme, $kind }) =>
    $kind === "exam" ? theme.colors.accent2 : theme.colors.accent600};
`;

export const StyledSummary = styled.p`
  margin: 14px 0 8px;
  font-size: 12.5px;
`;

export const StyledLegend = styled.ul`
  display: flex;
  flex-wrap: wrap;
  gap: 6px 14px;
  list-style: none;
  margin: 0;
  padding: 0;
  color: ${({ theme }) => theme.colors.muted};
  font-size: 11.5px;

  li {
    display: flex;
    align-items: center;
    gap: 5px;
  }
`;

export const StyledLegendSwatch = styled.span`
  width: 12px;
  height: 12px;
  border-radius: 4px;
  background: ${({ theme }) => theme.colors.accent100};
`;

export const StyledError = styled.p`
  margin: 10px 0 0;
  font-size: 12.5px;
  color: ${({ theme }) => theme.colors.danger600};
`;
