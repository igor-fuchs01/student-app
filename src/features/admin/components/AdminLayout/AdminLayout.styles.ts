import styled, { css } from "styled-components";
import { Link } from "react-router-dom";

export const StyledPage = styled.div`
  min-height: 100%;
  background: ${({ theme }) => theme.colors.bg};
`;

export const StyledHeader = styled.header`
  background: ${({ theme }) => theme.colors.surface};
  border-bottom: 1px solid ${({ theme }) => theme.colors.divider};
`;

export const StyledHeaderInner = styled.div`
  display: flex;
  align-items: center;
  gap: 8px 16px;
  flex-wrap: wrap;
  max-width: 1280px;
  margin: 0 auto;
  padding: 14px max(28px, env(safe-area-inset-right)) 14px max(28px, env(safe-area-inset-left));

  @media (max-width: ${({ theme }) => theme.breakpoints.sm}) {
    padding: 10px 16px;
  }
`;

export const StyledAreaLabel = styled.span`
  font-size: 11px;
  font-weight: 700;
  letter-spacing: 0.05em;
  text-transform: uppercase;
  color: ${({ theme }) => theme.colors.accent2600};
  background: ${({ theme }) => theme.colors.accent2100};
  border-radius: ${({ theme }) => theme.radii.pill};
  padding: 3px 10px;
`;

export const StyledNav = styled.nav`
  display: flex;
  align-items: center;
  gap: 4px;
  flex-wrap: wrap;
`;

const navItemStyles = css`
  display: inline-flex;
  align-items: center;
  min-height: 44px;
  padding: 6px 14px;
  border-radius: ${({ theme }) => theme.radii.pill};
  font-size: 13px;
`;

export const StyledNavLink = styled(Link)`
  ${navItemStyles}
  color: ${({ theme }) => theme.colors.muted};
  font-weight: 600;
  text-decoration: none;

  &:hover {
    background: ${({ theme }) => theme.colors.accent100};
    color: ${({ theme }) => theme.colors.accent600};
  }
`;

export const StyledNavLinkActive = styled.span`
  ${navItemStyles}
  background: ${({ theme }) => theme.colors.accent100};
  color: ${({ theme }) => theme.colors.accent600};
  font-weight: 700;
`;

export const StyledHeaderActions = styled.div`
  margin-left: auto;
`;

export const StyledContent = styled.main`
  max-width: 1280px;
  margin: 0 auto;
  padding: 26px max(28px, env(safe-area-inset-right)) 64px max(28px, env(safe-area-inset-left));

  @media (max-width: ${({ theme }) => theme.breakpoints.sm}) {
    padding: 18px 16px 48px;
  }
`;

export const StyledPageHeader = styled.div`
  display: flex;
  align-items: flex-start;
  justify-content: space-between;
  gap: 12px 20px;
  flex-wrap: wrap;
  margin-bottom: 20px;
`;

export const StyledPageTitle = styled.h1`
  font-weight: 700;
  font-size: 20px;
  margin: 0 0 4px;
`;

export const StyledPageSubtitle = styled.p`
  color: ${({ theme }) => theme.colors.muted};
  font-size: 13px;
  margin: 0;
  max-width: 640px;
`;

export const StyledPageActions = styled.div`
  display: flex;
  gap: 10px;
  flex-wrap: wrap;
`;
