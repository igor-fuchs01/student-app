import styled from "styled-components";

export const StyledSummary = styled.section`
  display: flex;
  flex-direction: column;
  gap: 10px;
`;

export const StyledHeading = styled.h2`
  font-family: ${({ theme }) => theme.fonts.heading};
  font-size: 13px;
  font-weight: 700;
  margin: 0;
`;

export const StyledTopicList = styled.ul`
  display: grid;
  grid-template-columns: repeat(auto-fill, minmax(260px, 1fr));
  gap: 10px 24px;
  list-style: none;
  margin: 0;
  padding: 0;

  @media (max-width: ${({ theme }) => theme.breakpoints.sm}) {
    grid-template-columns: 1fr;
  }
`;

export const StyledTopicName = styled.p`
  font-size: 13px;
  font-weight: 600;
  margin: 0 0 2px;
`;

export const StyledSubtopics = styled.p`
  color: ${({ theme }) => theme.colors.muted};
  font-size: 12.5px;
  line-height: 1.5;
  margin: 0;
`;

export const StyledEmpty = styled.p`
  color: ${({ theme }) => theme.colors.muted};
  font-size: 12.5px;
  margin: 0;
`;
