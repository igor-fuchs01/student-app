import styled from "styled-components";
import { Link } from "react-router-dom";
import { Card } from "@components/ui/Card";

export const StyledPageTitle = styled.h1`
  font-family: ${({ theme }) => theme.fonts.heading};
  font-weight: 700;
  font-size: 20px;
  margin: 0 0 4px;
`;

export const StyledPageSubtitle = styled.p`
  color: ${({ theme }) => theme.colors.muted};
  font-size: 13px;
  margin: 0 0 12px;
`;

export const StyledAllLink = styled(Link)`
  display: inline-block;
  color: ${({ theme }) => theme.colors.accent600};
  font-size: 12.5px;
  font-weight: 700;
  text-decoration: none;
  margin-bottom: 8px;

  &:hover {
    text-decoration: underline;
  }
`;

export const StyledSubjectSection = styled.section`
  margin-top: 20px;
`;

export const StyledSubjectTitle = styled.h2`
  font-family: ${({ theme }) => theme.fonts.heading};
  font-weight: 700;
  font-size: 15px;
  margin: 0 0 12px;
`;

export const StyledGrid = styled.div`
  display: grid;
  grid-template-columns: repeat(3, 1fr);
  gap: 16px;

  @media (max-width: ${({ theme }) => theme.breakpoints.md}) {
    grid-template-columns: 1fr;
  }
`;

export const StyledExerciseCard = styled(Card)`
  display: flex;
  flex-direction: column;
  align-items: flex-start;
  gap: 8px;
  padding: 18px;
`;

export const StyledExerciseTitle = styled.div`
  font-family: ${({ theme }) => theme.fonts.heading};
  font-weight: 700;
  font-size: 15px;
`;

export const StyledExerciseMeta = styled.p`
  color: ${({ theme }) => theme.colors.muted};
  font-size: 12.5px;
  margin: 0;
`;

export const StyledCardFooter = styled.div`
  margin-top: auto;
  padding-top: 6px;
`;
