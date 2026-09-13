import styled from "styled-components";
import { Card } from "@components/ui/Card";

export const StyledPage = styled.div`
  min-height: 100%;
  background: ${({ theme }) => theme.colors.bg};
`;

export const StyledHeader = styled.header`
  position: sticky;
  top: 0;
  z-index: 10;
  background: ${({ theme }) => theme.colors.surface};
  border-bottom: 1px solid ${({ theme }) => theme.colors.divider};
`;

export const StyledHeaderInner = styled.div`
  display: flex;
  align-items: center;
  gap: 6px;
  padding: 14px 28px;
  max-width: 1280px;
  margin: 0 auto;
  flex-wrap: wrap;
`;

export const StyledBrand = styled.span`
  font-family: "Poppins", sans-serif;
  font-weight: 800;
  font-size: 14px;
  margin-right: 20px;
`;

export const StyledNav = styled.nav`
  display: flex;
  align-items: center;
  gap: 4px;
  flex-wrap: wrap;
`;

export const StyledNavLinkActive = styled.span`
  background: ${({ theme }) => theme.colors.accent100};
  color: ${({ theme }) => theme.colors.accent600};
  font-size: 12.5px;
  font-weight: 700;
  padding: 6px 12px;
  border-radius: ${({ theme }) => theme.radii.pill};
`;

export const StyledNavLinkDisabled = styled.span`
  color: ${({ theme }) => theme.colors.muted};
  font-size: 12.5px;
  font-weight: 600;
  padding: 6px 12px;
  cursor: not-allowed;
`;

export const StyledHeaderActions = styled.div`
  margin-left: auto;
  display: flex;
  align-items: center;
  gap: 12px;

  @media (max-width: 860px) {
    margin-left: 0;
    width: 100%;
    justify-content: space-between;
  }
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

export const StyledGreeting = styled.p`
  color: ${({ theme }) => theme.colors.muted};
  font-size: 13px;
  margin: 0 0 2px;
`;

export const StyledPageTitle = styled.h1`
  font-weight: 700;
  font-size: 20px;
  margin: 0 0 20px;
`;

export const StyledMainGrid = styled.div`
  display: grid;
  grid-template-columns: 1.4fr 1fr;
  gap: 18px;
  margin-bottom: 18px;

  @media (max-width: 860px) {
    grid-template-columns: 1fr;
  }
`;

export const StyledEyebrow = styled.span`
  color: ${({ theme }) => theme.colors.accent600};
  font-size: 11px;
  font-weight: 700;
  letter-spacing: 0.05em;
  text-transform: uppercase;
`;

export const StyledExamSubject = styled.div`
  font-family: "Poppins", sans-serif;
  font-weight: 700;
  font-size: 19px;
  margin: 4px 0;
`;

export const StyledExamMeta = styled.div`
  color: ${({ theme }) => theme.colors.muted};
  font-size: 13px;
  margin-bottom: 14px;
`;

export const StyledProgressLabel = styled.p`
  color: ${({ theme }) => theme.colors.muted};
  font-size: 12px;
  margin: 0 0 4px;
`;

export const StyledProgressValue = styled.p`
  font-size: 13px;
  font-weight: 700;
  margin: 4px 0 16px;
`;

export const StyledPriorityList = styled.ul`
  list-style: none;
  margin: 0;
  padding: 0;
  display: flex;
  flex-direction: column;
  gap: 8px;
`;

export const StyledPriorityItem = styled.li`
  display: flex;
  justify-content: space-between;
  align-items: center;
  font-size: 13px;
`;

export const StyledPlanList = styled.ul`
  list-style: none;
  margin: 10px 0 0;
  padding: 0;
  display: flex;
  flex-direction: column;
  gap: 12px;
`;

export const StyledPlanItemLabel = styled.label<{ $done: boolean }>`
  display: flex;
  align-items: center;
  gap: 10px;
  font-size: 13px;
  cursor: pointer;
  opacity: ${({ $done }) => ($done ? 0.5 : 1)};
  text-decoration: ${({ $done }) => ($done ? "line-through" : "none")};

  input {
    width: 18px;
    height: 18px;
    accent-color: ${({ theme }) => theme.colors.accent};
  }
`;

export const StyledSummaryGrid = styled.div`
  display: grid;
  grid-template-columns: repeat(3, 1fr);
  gap: 16px;

  @media (max-width: 860px) {
    grid-template-columns: 1fr;
  }
`;

export const StyledSummaryCard = styled(Card)`
  padding: 18px;
`;

export const StyledSummaryValue = styled.div`
  font-family: "Poppins", sans-serif;
  font-weight: 700;
  font-size: 16px;
  margin: 4px 0;
`;

export const StyledSummaryDescription = styled.p`
  color: ${({ theme }) => theme.colors.muted};
  font-size: 12.5px;
  margin: 0;
`;
