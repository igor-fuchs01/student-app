import styled from "styled-components";
import { Card } from "@components/ui/Card";

export const StyledCard = styled(Card)`
  display: flex;
  flex-direction: column;
  gap: 10px;
  padding: 18px;
  height: 100%;
`;

export const StyledName = styled.h2`
  font-family: ${({ theme }) => theme.fonts.heading};
  font-size: 16px;
  font-weight: 700;
  margin: 0;
`;

export const StyledBadges = styled.div`
  display: flex;
  flex-wrap: wrap;
  gap: 6px;
`;

export const StyledDescription = styled.p`
  color: ${({ theme }) => theme.colors.muted};
  font-size: 13px;
  line-height: 1.5;
  margin: 0;
`;

export const StyledOffices = styled.ul`
  display: flex;
  flex-direction: column;
  gap: 12px;
  list-style: none;
  margin: 4px 0 0;
  padding: 12px 0 0;
  border-top: 1px solid ${({ theme }) => theme.colors.divider};
`;

export const StyledOfficeLabel = styled.p`
  font-size: 11px;
  font-weight: 700;
  letter-spacing: 0.05em;
  text-transform: uppercase;
  color: ${({ theme }) => theme.colors.muted};
  margin: 0 0 2px;
`;

export const StyledAddress = styled.p`
  font-size: 13px;
  margin: 0;
`;

export const StyledRouteLink = styled.a`
  display: inline-flex;
  align-items: center;
  min-height: 44px;
  color: ${({ theme }) => theme.colors.accent600};
  font-size: 13px;
  font-weight: 600;

  &:focus-visible {
    outline: 2px solid ${({ theme }) => theme.colors.accent};
    outline-offset: 2px;
    border-radius: 4px;
  }
`;

export const StyledNoOffice = styled.p`
  color: ${({ theme }) => theme.colors.muted};
  font-size: 13px;
  margin: 4px 0 0;
  padding-top: 12px;
  border-top: 1px solid ${({ theme }) => theme.colors.divider};
`;

export const StyledVisuallyHidden = styled.span`
  position: absolute;
  width: 1px;
  height: 1px;
  overflow: hidden;
  clip: rect(0 0 0 0);
  white-space: nowrap;
`;
