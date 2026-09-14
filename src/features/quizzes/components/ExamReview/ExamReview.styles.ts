import styled from "styled-components";
import { Card } from "@components/ui/Card";

export const StyledExamLayout = styled.div`
  display: flex;
  gap: 24px;
  align-items: flex-start;
  flex-wrap: wrap;
`;

export const StyledExamMain = styled.div`
  flex: 1;
  min-width: 280px;
`;

export const StyledExamSidebar = styled(Card)`
  width: 320px;
  flex: none;
  padding: 20px;
`;

export const StyledExamSidebarLabel = styled.div`
  color: ${({ theme }) => theme.colors.muted};
  font-size: 11px;
  letter-spacing: 0.05em;
  text-transform: uppercase;
  margin-bottom: 10px;
`;
