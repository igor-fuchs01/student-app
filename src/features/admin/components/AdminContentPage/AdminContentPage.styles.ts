import styled from "styled-components";
import { Card } from "@components/ui/Card";

export const StyledSubjectCard = styled(Card)`
  margin-bottom: 16px;
`;

export const StyledRow = styled.div`
  display: flex;
  align-items: center;
  justify-content: space-between;
  gap: 4px 16px;
  flex-wrap: wrap;
`;

export const StyledSubjectName = styled.h2`
  font-weight: 700;
  font-size: 17px;
  margin: 0;

  span {
    color: ${({ theme }) => theme.colors.muted};
    font-family: ${({ theme }) => theme.fonts.body};
    font-size: 12.5px;
    font-weight: 600;
    margin-left: 8px;
  }
`;

export const StyledTopic = styled.section`
  border-top: 1px solid ${({ theme }) => theme.colors.divider};
  margin-top: 12px;
  padding-top: 12px;
`;

export const StyledTopicName = styled.h3`
  font-weight: 700;
  font-size: 14.5px;
  margin: 0;
`;

export const StyledDescription = styled.p`
  color: ${({ theme }) => theme.colors.muted};
  font-size: 12.5px;
  margin: 2px 0 0;
`;

export const StyledSubtopics = styled.ul`
  list-style: none;
  margin: 8px 0 0;
  padding: 0 0 0 16px;
  border-left: 2px solid ${({ theme }) => theme.colors.accent100};
`;

export const StyledSubtopicName = styled.span`
  font-size: 13.5px;
  font-weight: 600;

  small {
    color: ${({ theme }) => theme.colors.muted};
    font-size: 12px;
    font-weight: 400;
    margin-left: 8px;
  }
`;

export const StyledActions = styled.div`
  display: flex;
  flex-wrap: wrap;
  gap: 0 4px;
`;
