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
  margin: 0 0 14px;
`;

export const StyledHighlight = styled.div`
  flex: none;
  display: flex;
  flex-direction: column;
  align-items: flex-start;
  gap: 2px;
  padding: 16px;
  border-radius: ${({ theme }) => theme.radii.md};
  background: ${({ theme }) => theme.colors.accent100};

  > button {
    margin-top: 10px;
  }
`;

export const StyledHighlightName = styled.p`
  margin: 0;
  font-family: ${({ theme }) => theme.fonts.heading};
  font-size: 16px;
  font-weight: 700;
  line-height: 1.3;
`;

export const StyledTopicMeta = styled.span`
  font-size: 12px;
  color: ${({ theme }) => theme.colors.muted};
`;

export const StyledAction = styled.span`
  font-size: 12.5px;
  font-weight: 600;
  color: ${({ theme }) => theme.colors.accent600};
`;

export const StyledNextLabel = styled.p`
  flex: none;
  margin: 18px 0 4px;
  font-size: 12px;
  font-weight: 600;
  color: ${({ theme }) => theme.colors.muted};
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
  align-items: baseline;
  justify-content: space-between;
  gap: 12px;
  padding: 8px 0;
  border-top: 1px solid ${({ theme }) => theme.colors.divider};
  visibility: ${({ $hidden }) => ($hidden ? "hidden" : "visible")};

  &:first-child {
    border-top: 0;
    padding-top: 0;
  }
`;

export const StyledTopicName = styled.span`
  min-width: 0;
  overflow: hidden;
  text-overflow: ellipsis;
  white-space: nowrap;
  font-size: 13px;
  font-weight: 500;
`;

export const StyledPercent = styled.span`
  flex: none;
  font-size: 12.5px;
  color: ${({ theme }) => theme.colors.muted};
  font-variant-numeric: tabular-nums;
`;

export const StyledMore = styled.p`
  flex: none;
  margin: 6px 0 0;
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
