import styled from "styled-components";
import { Card } from "@components/ui/Card";

export const StyledRow = styled(Card)`
  display: flex;
  align-items: center;
  justify-content: space-between;
  gap: 8px 16px;
  flex-wrap: wrap;
  padding: 12px 16px;
  margin-bottom: 10px;
`;

export const StyledText = styled.div`
  flex: 1 1 260px;
  min-width: 0;
`;

export const StyledStatement = styled.p`
  margin: 0 0 6px;
  font-size: 13.5px;
  display: -webkit-box;
  -webkit-line-clamp: 2;
  -webkit-box-orient: vertical;
  overflow: hidden;
`;

export const StyledMeta = styled.div`
  display: flex;
  align-items: center;
  gap: 6px;
  flex-wrap: wrap;
  color: ${({ theme }) => theme.colors.muted};
  font-size: 12px;
`;

export const StyledActions = styled.div`
  display: flex;
  flex-wrap: wrap;
  gap: 0 4px;
`;
