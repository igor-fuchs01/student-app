import styled from "styled-components";
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
  font-family: ${({ theme }) => theme.fonts.heading};
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

export const StyledFooter = styled.div`
  display: flex;
  justify-content: space-between;
  align-items: center;
  gap: 12px;
  margin-top: 24px;
  flex-wrap: wrap;
`;
