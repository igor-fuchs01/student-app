import styled from "styled-components";
import { Card } from "@components/ui/Card";

export const StyledFormCard = styled(Card)`
  margin-bottom: 20px;
`;

export const StyledFields = styled.div`
  display: grid;
  grid-template-columns: repeat(3, 1fr);
  gap: 0 14px;

  @media (max-width: ${({ theme }) => theme.breakpoints.md}) {
    grid-template-columns: 1fr;
  }
`;

export const StyledColumns = styled.div`
  display: grid;
  grid-template-columns: 1fr 1fr;
  gap: 20px;
  align-items: start;

  @media (max-width: ${({ theme }) => theme.breakpoints.md}) {
    grid-template-columns: 1fr;
  }
`;

export const StyledSectionTitle = styled.h2`
  font-weight: 700;
  font-size: 15px;
  margin: 0 0 4px;
`;

export const StyledSectionHint = styled.p`
  color: ${({ theme }) => theme.colors.muted};
  font-size: 12.5px;
  margin: 0 0 12px;
`;

export const StyledFooter = styled.div`
  display: flex;
  justify-content: flex-end;
  gap: 10px;
  margin-top: 20px;

  @media (max-width: ${({ theme }) => theme.breakpoints.sm}) {
    flex-direction: column-reverse;
  }
`;
