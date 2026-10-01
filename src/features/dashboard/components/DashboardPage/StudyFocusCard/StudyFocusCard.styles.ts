import styled from "styled-components";
import { Card } from "@components/ui/Card";

export const StyledStudyFocusCard = styled(Card)`
  display: flex;
  flex-direction: column;
  min-width: 0;
  border: 1px solid ${({ theme }) => theme.colors.divider};
  min-height: 0;
  padding: 18px 22px;
  overflow: hidden;
`;

export const StyledTitle = styled.h2`
  font-size: 15px;
  font-weight: 700;
  line-height: 1.3;
  margin: 0;
`;

export const StyledSubtitle = styled.p`
  font-size: 12.5px;
  color: ${({ theme }) => theme.colors.muted};
  margin: 2px 0 12px;
`;

export const StyledList = styled.ul`
  flex: 1;
  min-height: 0;
  overflow: hidden;
  list-style: none;
  margin: 0;
  padding: 0;
`;

export const StyledItem = styled.li<{ $hidden: boolean }>`
  display: flex;
  flex-direction: column;
  gap: 6px;
  padding: 12px 0;
  border-top: 1px solid ${({ theme }) => theme.colors.divider};
  visibility: ${({ $hidden }) => ($hidden ? "hidden" : "visible")};

  &:first-child {
    border-top: 0;
    padding-top: 0;
  }
`;

export const StyledItemTop = styled.div`
  display: flex;
  align-items: flex-start;
  justify-content: space-between;
  gap: 10px;
`;

export const StyledTopicName = styled.div`
  min-width: 0;
  font-size: 13.5px;
  font-weight: 600;
`;

export const StyledTopicMeta = styled.span`
  display: block;
  font-size: 11.5px;
  font-weight: 500;
  color: ${({ theme }) => theme.colors.muted};
`;

export const StyledAccuracy = styled.div`
  display: flex;
  align-items: center;
  gap: 10px;
  font-size: 12px;

  > :first-child {
    flex: 1;
  }

  b {
    width: 34px;
    text-align: right;
    font-variant-numeric: tabular-nums;
  }
`;

export const StyledAction = styled.span`
  font-size: 12px;
  font-weight: 600;
  color: ${({ theme }) => theme.colors.accent600};
`;

export const StyledMore = styled.p`
  flex: none;
  margin: 4px 0 12px;
  font-size: 12px;
  color: ${({ theme }) => theme.colors.muted};
`;

export const StyledEmpty = styled.p`
  flex: 1;
  display: grid;
  place-items: center;
  margin: 0;
  text-align: center;
  color: ${({ theme }) => theme.colors.muted};
  font-size: 13px;
`;
