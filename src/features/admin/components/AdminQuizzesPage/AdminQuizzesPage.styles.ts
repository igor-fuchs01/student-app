import styled from "styled-components";
import { Card } from "@components/ui/Card";

export const StyledQuizCard = styled(Card)`
  display: flex;
  align-items: center;
  justify-content: space-between;
  gap: 8px 16px;
  flex-wrap: wrap;
  padding: 14px 18px;
  margin-bottom: 10px;
`;

export const StyledQuizText = styled.div`
  flex: 1 1 320px;
  min-width: 0;
`;

export const StyledQuizTitle = styled.h2`
  font-weight: 700;
  font-size: 15px;
  margin: 0 0 6px;
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
