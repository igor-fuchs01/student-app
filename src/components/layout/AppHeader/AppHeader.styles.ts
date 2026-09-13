import styled from "styled-components";
import { Link } from "react-router-dom";

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

export const StyledNavLink = styled(Link)`
  color: ${({ theme }) => theme.colors.muted};
  text-decoration: none;
  font-size: 12.5px;
  font-weight: 600;
  padding: 6px 12px;
  border-radius: ${({ theme }) => theme.radii.pill};

  &:hover {
    background: ${({ theme }) => theme.colors.accent100};
    color: ${({ theme }) => theme.colors.accent600};
  }
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
