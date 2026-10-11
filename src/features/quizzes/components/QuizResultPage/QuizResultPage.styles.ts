import styled from "styled-components";

export const StyledHeaderRow = styled.div`
  display: flex;
  justify-content: space-between;
  align-items: flex-start;
  gap: 16px;
  flex-wrap: wrap;
  margin-bottom: 22px;
`;

export const StyledTitle = styled.h1`
  font-family: ${({ theme }) => theme.fonts.heading};
  font-weight: 700;
  font-size: 18px;
  margin: 0 0 4px;
`;

export const StyledSubmittedAt = styled.p`
  color: ${({ theme }) => theme.colors.muted};
  font-size: 13px;
  margin: 0;
`;

export const StyledScoreBox = styled.div`
  text-align: right;
  background: ${({ theme }) => theme.colors.accent100};
  border-radius: ${({ theme }) => theme.radii.lg};
  padding: 14px 22px;
`;

export const StyledScoreValue = styled.div`
  font-family: ${({ theme }) => theme.fonts.heading};
  font-weight: 800;
  font-size: 34px;
  line-height: 1;
  color: ${({ theme }) => theme.colors.accent600};
`;

export const StyledScoreLabel = styled.div`
  color: ${({ theme }) => theme.colors.muted};
  font-size: 12px;
`;

export const StyledBadgeRow = styled.div`
  display: flex;
  gap: 10px;
  margin-bottom: 28px;
  flex-wrap: wrap;
`;

export const StyledColumns = styled.div`
  display: grid;
  grid-template-columns: 1fr 1fr;
  gap: 28px;

  @media (max-width: ${({ theme }) => theme.breakpoints.md}) {
    grid-template-columns: 1fr;
  }
`;

export const StyledColumnTitle = styled.h2`
  font-family: ${({ theme }) => theme.fonts.heading};
  font-weight: 700;
  font-size: 15px;
  margin: 0 0 14px;
`;

export const StyledPerformanceList = styled.div`
  display: flex;
  flex-direction: column;
  gap: 16px;
`;

export const StyledPerformanceHeader = styled.div`
  display: flex;
  justify-content: space-between;
  font-size: 13px;
  margin-bottom: 5px;

  span:last-child {
    font-weight: 700;
  }
`;

export const StyledPageActions = styled.div`
  display: flex;
  justify-content: space-between;
  gap: 12px;
  flex-wrap: wrap;
  margin-top: 32px;
  padding-top: 20px;
  border-top: 1px solid ${({ theme }) => theme.colors.divider};

  @media (max-width: ${({ theme }) => theme.breakpoints.sm}) {
    flex-direction: column-reverse;
    align-items: stretch;
  }
`;
