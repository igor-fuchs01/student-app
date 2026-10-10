import styled from "styled-components";
import { Card } from "@components/ui/Card";

export const StyledFormCard = styled(Card)`
  max-width: 820px;

  textarea {
    min-height: 360px;
    font-family: ui-monospace, "Cascadia Code", Consolas, monospace;
    font-size: 12.5px;
  }
`;

export const StyledFooter = styled.div`
  display: flex;
  justify-content: flex-end;
  gap: 10px;

  @media (max-width: ${({ theme }) => theme.breakpoints.sm}) {
    flex-direction: column-reverse;
  }
`;
