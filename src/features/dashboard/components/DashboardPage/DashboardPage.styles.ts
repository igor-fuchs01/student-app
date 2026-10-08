import styled, { type DefaultTheme } from "styled-components";
import { Card } from "@components/ui/Card";

const fitViewport = ({ theme }: { theme: DefaultTheme }) =>
  `(min-width: ${theme.breakpoints.md}) and (min-height: 560px)`;

export const StyledDashboard = styled.div<{ $updating: boolean }>`
  display: flex;
  flex-direction: column;
  gap: 16px;
  transition: opacity 0.2s ease;
  opacity: ${({ $updating }) => ($updating ? 0.6 : 1)};

  @media ${fitViewport} {
    flex: 1;
    min-height: 0;
  }
`;

export const StyledHead = styled.div`
  flex: none;
  display: flex;
  align-items: center;
  justify-content: space-between;
  gap: 10px 24px;
  flex-wrap: wrap;
`;

export const StyledGreeting = styled.h1`
  font-size: 22px;
  font-weight: 700;
  line-height: 1.2;
  margin: 0;
`;

export const StyledSubtitle = styled.p`
  color: ${({ theme }) => theme.colors.muted};
  font-size: 13px;
  margin: 2px 0 0;
`;

export const StyledGrid = styled.div`
  display: grid;
  grid-template-columns: minmax(0, 1fr);
  gap: 16px;

  @media ${fitViewport} {
    flex: 1;
    min-height: 0;
    grid-template-rows: auto minmax(0, 1fr);
  }
`;

export const StyledKpis = styled.div`
  display: grid;
  grid-template-columns: repeat(3, minmax(0, 1fr));
  gap: 16px;

  @media (max-width: ${({ theme }) => theme.breakpoints.sm}) {
    grid-template-columns: minmax(0, 1fr);
  }
`;

export const StyledCharts = styled.div`
  display: grid;
  grid-template-columns: minmax(0, 1fr);
  gap: 16px;

  @media ${fitViewport} {
    min-height: 0;
    grid-template-columns: minmax(0, 1.25fr) minmax(0, 1fr);
  }
`;

export const StyledEmptyState = styled(Card)`
  display: flex;
  flex-direction: column;
  align-items: flex-start;
  gap: 12px;
  border: 1px solid ${({ theme }) => theme.colors.divider};

  h2 {
    font-size: 17px;
    margin: 0;
  }

  p {
    color: ${({ theme }) => theme.colors.muted};
    font-size: 13.5px;
    margin: 0;
  }
`;
