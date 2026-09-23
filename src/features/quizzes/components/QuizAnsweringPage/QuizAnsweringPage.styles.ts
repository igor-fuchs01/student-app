import styled, { css } from "styled-components";
import { Card } from "@components/ui/Card";

const touchTarget = css`
  @media (max-width: ${({ theme }) => theme.breakpoints.sm}) {
    width: 44px;
    height: 44px;
    font-size: 16px;
  }
`;

export const StyledTopBar = styled.div`
  display: flex;
  align-items: center;
  justify-content: space-between;
  flex-wrap: wrap;
  gap: 12px;
  margin-bottom: 20px;

  @media (max-width: ${({ theme }) => theme.breakpoints.sm}) {
    position: sticky;
    top: 0;
    z-index: 20;
    gap: 4px 12px;
    margin: -18px -16px 16px;
    padding: 10px 16px;
    background: ${({ theme }) => theme.colors.bg};
    border-bottom: 1px solid ${({ theme }) => theme.colors.divider};
  }
`;

export const StyledTopBarTitle = styled.h1`
  font-family: ${({ theme }) => theme.fonts.heading};
  font-weight: 700;
  font-size: 16px;
  margin: 0;

  @media (max-width: ${({ theme }) => theme.breakpoints.sm}) {
    width: 100%;
    font-size: 14px;
    overflow: hidden;
    white-space: nowrap;
    text-overflow: ellipsis;
  }
`;

export const StyledTopBarMeta = styled.div`
  display: flex;
  align-items: center;
  gap: 18px;

  @media (max-width: ${({ theme }) => theme.breakpoints.sm}) {
    width: 100%;
    gap: 8px;

    & > :first-child {
      margin-right: auto;
    }
  }
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

  ${touchTarget}
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

  @media (max-width: ${({ theme }) => theme.breakpoints.sm}) {
    min-width: 0;
    padding: 20px 16px;
  }
`;

export const StyledSheetBackdrop = styled.div`
  display: none;

  @media (max-width: ${({ theme }) => theme.breakpoints.sm}) {
    display: block;
    position: fixed;
    inset: 0;
    z-index: 50;
    background: rgba(20, 20, 15, 0.45);
  }
`;

export const StyledSidebar = styled(Card)<{ $open: boolean }>`
  width: 320px;
  flex: none;
  padding: 20px;

  @media (max-width: ${({ theme }) => theme.breakpoints.sm}) {
    position: fixed;
    left: 0;
    right: 0;
    bottom: 0;
    z-index: 60;
    width: auto;
    max-height: 75vh;
    overflow-y: auto;
    padding: 12px 16px calc(20px + env(safe-area-inset-bottom));
    border-radius: ${({ theme }) => `${theme.radii.lg} ${theme.radii.lg} 0 0`};
    box-shadow: ${({ theme }) => theme.shadows.md};
    transition:
      transform 0.2s ease,
      visibility 0.2s;
    transform: translateY(${({ $open }) => ($open ? "0" : "100%")});
    visibility: ${({ $open }) => ($open ? "visible" : "hidden")};
  }
`;

export const StyledSheetHandle = styled.div`
  display: none;

  @media (max-width: ${({ theme }) => theme.breakpoints.sm}) {
    display: block;
    width: 40px;
    height: 4px;
    margin: 0 auto 12px;
    border-radius: ${({ theme }) => theme.radii.pill};
    background: ${({ theme }) => theme.colors.divider};
  }
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

export const StyledSidebarActions = styled.div`
  display: flex;
  align-items: center;
  gap: 8px;
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

  ${touchTarget}
`;

export const StyledSheetClose = styled.button`
  display: none;

  @media (max-width: ${({ theme }) => theme.breakpoints.sm}) {
    display: inline-flex;
    align-items: center;
    justify-content: center;
    width: 44px;
    height: 44px;
    border: none;
    border-radius: ${({ theme }) => theme.radii.pill};
    background: rgba(0, 0, 0, 0.05);
    color: ${({ theme }) => theme.colors.text};
    font-size: 16px;
    line-height: 1;
  }
`;

export const StyledGridToggle = styled.button`
  display: none;

  @media (max-width: ${({ theme }) => theme.breakpoints.sm}) {
    display: inline-flex;
    align-items: center;
    justify-content: center;
    flex: none;
    width: 46px;
    height: 46px;
    border-radius: ${({ theme }) => theme.radii.pill};
    border: 1.5px solid ${({ theme }) => theme.colors.divider};
    background: transparent;
    color: ${({ theme }) => theme.colors.text};
    font-size: 18px;
    line-height: 1;
  }
`;

export const StyledFooter = styled.div`
  display: flex;
  justify-content: space-between;
  align-items: center;
  gap: 12px;
  margin-top: 24px;
  flex-wrap: wrap;

  @media (max-width: ${({ theme }) => theme.breakpoints.sm}) {
    position: fixed;
    left: 0;
    right: 0;
    bottom: 0;
    z-index: 40;
    flex-wrap: nowrap;
    gap: 8px;
    margin: 0;
    padding: 10px 16px calc(10px + env(safe-area-inset-bottom));
    background: ${({ theme }) => theme.colors.surface};
    border-top: 1px solid ${({ theme }) => theme.colors.divider};
    box-shadow: ${({ theme }) => theme.shadows.sm};

    & > button:not(${StyledGridToggle}) {
      flex: 1;
      padding-left: 12px;
      padding-right: 12px;
    }
  }
`;
