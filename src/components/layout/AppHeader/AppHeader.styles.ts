import styled, { css } from "styled-components";
import { Link } from "react-router-dom";

export const StyledHeader = styled.header`
  position: sticky;
  top: 0;
  z-index: 10;
  background: ${({ theme }) => theme.colors.surface};
  border-bottom: 1px solid ${({ theme }) => theme.colors.divider};

  @media (max-width: ${({ theme }) => theme.breakpoints.sm}) {
    position: static;
  }
`;

export const StyledHeaderInner = styled.div`
  display: flex;
  align-items: center;
  gap: 6px;
  padding: 14px max(28px, env(safe-area-inset-right)) 14px max(28px, env(safe-area-inset-left));
  max-width: 1280px;
  margin: 0 auto;
  flex-wrap: wrap;

  @media (max-width: ${({ theme }) => theme.breakpoints.sm}) {
    padding: 10px 16px;
  }
`;

export const StyledBrand = styled.span`
  font-family: ${({ theme }) => theme.fonts.heading};
  font-weight: 800;
  font-size: 14px;
  margin-right: 20px;
`;

export const StyledNav = styled.nav<{ $hideOnMobile: boolean }>`
  display: flex;
  align-items: center;
  gap: 4px;
  flex-wrap: wrap;

  @media (max-width: ${({ theme }) => theme.breakpoints.sm}) {
    position: fixed;
    left: 0;
    right: 0;
    bottom: 0;
    display: ${({ $hideOnMobile }) => ($hideOnMobile ? "none" : "grid")};
    grid-template-columns: repeat(4, 1fr);
    gap: 0;
    padding: 6px 8px calc(6px + env(safe-area-inset-bottom));
    background: ${({ theme }) => theme.colors.surface};
    border-top: 1px solid ${({ theme }) => theme.colors.divider};
    box-shadow: ${({ theme }) => theme.shadows.sm};
  }
`;

const navItemStyles = css`
  font-size: 12.5px;
  padding: 6px 12px;
  border-radius: ${({ theme }) => theme.radii.pill};

  @media (max-width: ${({ theme }) => theme.breakpoints.sm}) {
    display: flex;
    flex-direction: column;
    align-items: center;
    justify-content: center;
    gap: 2px;
    min-height: 52px;
    padding: 4px;
    font-size: 11px;
    border-radius: ${({ theme }) => theme.radii.md};
  }
`;

export const StyledNavLink = styled(Link)`
  ${navItemStyles}
  color: ${({ theme }) => theme.colors.muted};
  text-decoration: none;
  font-weight: 600;

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

export const StyledNavIcon = styled.span`
  display: none;
  font-size: 18px;
  line-height: 1;

  @media (max-width: ${({ theme }) => theme.breakpoints.sm}) {
    display: block;
  }
`;

export const StyledHeaderActions = styled.div`
  margin-left: auto;
  display: flex;
  align-items: center;
  gap: 12px;

  @media (max-width: ${({ theme }) => theme.breakpoints.md}) {
    margin-left: 0;
    width: 100%;
    justify-content: space-between;
  }

  @media (max-width: ${({ theme }) => theme.breakpoints.sm}) {
    margin-left: auto;
    width: auto;
    gap: 8px;
  }
`;
