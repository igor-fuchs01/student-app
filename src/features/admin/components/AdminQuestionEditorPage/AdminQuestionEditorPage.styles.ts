import styled from "styled-components";
import { Card } from "@components/ui/Card";

export const StyledFormCard = styled(Card)`
  max-width: 820px;
`;

export const StyledColumns = styled.div`
  display: grid;
  grid-template-columns: repeat(3, 1fr);
  gap: 0 14px;

  @media (max-width: ${({ theme }) => theme.breakpoints.md}) {
    grid-template-columns: 1fr;
  }
`;

export const StyledItem = styled.div`
  border-bottom: 1px dashed ${({ theme }) => theme.colors.divider};
  margin-bottom: 12px;
`;

export const StyledFooter = styled.div`
  display: flex;
  justify-content: flex-end;
  gap: 10px;
  margin-top: 8px;

  @media (max-width: ${({ theme }) => theme.breakpoints.sm}) {
    flex-direction: column-reverse;
  }
`;
