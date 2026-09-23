import styled from "styled-components";
import { Card } from "@components/ui/Card";

export const StyledSectionHeader = styled.div`
  display: flex;
  align-items: center;
  justify-content: space-between;
  gap: 12px;
  flex-wrap: wrap;
  margin-top: 18px;
  margin-bottom: 14px;
`;

export const StyledSectionTitle = styled.h2`
  font-weight: 700;
  font-size: 16px;
  margin: 0;
`;

export const StyledFilterGroup = styled.div`
  display: flex;
  align-items: center;
  gap: 6px;
  flex-wrap: wrap;
`;

export const StyledFilterChip = styled.button<{ $active: boolean }>`
  border: none;
  cursor: pointer;
  font-size: 12px;
  font-weight: 700;
  padding: 6px 14px;
  border-radius: ${({ theme }) => theme.radii.pill};
  background: ${({ theme, $active }) => ($active ? theme.colors.accent : theme.colors.surface2)};
  color: ${({ theme, $active }) => ($active ? "#fff" : theme.colors.text)};
  transition: opacity 0.15s ease;

  &:hover {
    opacity: 0.85;
  }
`;

export const StyledQuizList = styled.div`
  display: grid;
  grid-template-columns: repeat(3, 1fr);
  gap: 16px;

  @media (max-width: ${({ theme }) => theme.breakpoints.md}) {
    grid-template-columns: 1fr;
  }
`;

export const StyledQuizCard = styled(Card)`
  display: flex;
  flex-direction: column;
  gap: 8px;
  padding: 18px;
`;

export const StyledQuizCardTopRow = styled.div`
  display: flex;
  justify-content: space-between;
  align-items: flex-start;
  gap: 8px;
`;

export const StyledQuizTitle = styled.h3`
  font-family: ${({ theme }) => theme.fonts.heading};
  font-weight: 700;
  font-size: 15px;
  margin: 0;
`;

export const StyledQuizMeta = styled.p`
  color: ${({ theme }) => theme.colors.muted};
  font-size: 12.5px;
  margin: 0;
`;

export const StyledEmptyMessage = styled.p`
  color: ${({ theme }) => theme.colors.muted};
  font-size: 13px;
  margin: 0;
`;
