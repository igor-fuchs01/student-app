import styled from "styled-components";
import { Button } from "@components/ui/Button";

export const StyledPage = styled.div`
  min-height: 100%;
  display: flex;
  align-items: center;
  justify-content: center;
  padding: 24px;
  background: linear-gradient(
    160deg,
    ${({ theme }) => theme.colors.accent100},
    ${({ theme }) => theme.colors.bg} 55%
  );
`;

export const StyledFormCard = styled.form`
  width: 100%;
  max-width: 380px;
  background: ${({ theme }) => theme.colors.surface};
  border-radius: ${({ theme }) => theme.radii.lg};
  padding: 36px;
  box-shadow: ${({ theme }) => theme.shadows.md};
`;

export const StyledBrand = styled.div`
  font-family: ${({ theme }) => theme.fonts.heading};
  font-weight: 800;
  font-size: 17px;
  margin-bottom: 28px;
`;

export const StyledTitle = styled.h1`
  font-weight: 700;
  font-size: 20px;
  margin: 0 0 22px;
`;

export const StyledForgotPassword = styled.a`
  display: inline-block;
  font-size: 12px;
  color: ${({ theme }) => theme.colors.accent600};
  font-weight: 600;
  text-decoration: none;

  &:hover {
    text-decoration: underline;
  }
`;

export const StyledSubmitButton = styled(Button)`
  width: 100%;
  display: block;
  margin-top: 20px;
`;

export const StyledFormError = styled.p`
  margin: 0 0 10px;
  font-size: 12.5px;
  color: ${({ theme }) => theme.colors.danger600};
  background: ${({ theme }) => theme.colors.danger100};
  border-radius: ${({ theme }) => theme.radii.md};
  padding: 10px 12px;
`;

export const StyledHint = styled.p`
  color: ${({ theme }) => theme.colors.muted};
  font-size: 11.5px;
  margin-top: 22px;
  line-height: 1.5;
`;
