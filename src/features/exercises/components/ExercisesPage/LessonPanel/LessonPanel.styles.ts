import styled from "styled-components";

export const StyledPanel = styled.section`
  display: flex;
  flex-direction: column;
  align-items: flex-start;
  gap: 10px;
  min-width: 0;
  padding: 24px;
  background: ${({ theme }) => theme.colors.surface};
  border-radius: ${({ theme }) => theme.radii.lg};
  box-shadow: ${({ theme }) => theme.shadows.sm};

  @media (max-width: ${({ theme }) => theme.breakpoints.sm}) {
    padding: 18px;
  }
`;

export const StyledBackButton = styled.button`
  display: none;
  min-height: 44px;
  padding: 0;
  border: 0;
  background: transparent;
  color: ${({ theme }) => theme.colors.accent600};
  font-size: 13px;
  font-weight: 700;

  @media (max-width: ${({ theme }) => theme.breakpoints.md}) {
    display: inline-block;
  }
`;

export const StyledEyebrow = styled.span`
  font-size: 11px;
  font-weight: 700;
  letter-spacing: 0.05em;
  text-transform: uppercase;
  color: ${({ theme }) => theme.colors.accent600};
`;

export const StyledLessonName = styled.h2`
  margin: 0;
  font-size: 20px;
  font-weight: 700;
  line-height: 1.3;
`;

export const StyledProgress = styled.div`
  display: flex;
  align-items: center;
  gap: 12px;
  width: 100%;
  max-width: 420px;
  margin-bottom: 6px;

  > :first-child {
    flex: 1;
  }
`;

export const StyledProgressLabel = styled.span`
  flex: none;
  font-size: 12.5px;
  color: ${({ theme }) => theme.colors.muted};
`;

export const StyledSection = styled.div`
  width: 100%;
  margin-top: 18px;
`;

export const StyledSectionTitle = styled.h3`
  margin: 0 0 8px;
  font-size: 14px;
  font-weight: 700;
`;

export const StyledSummary = styled.p`
  margin: 0 0 10px;
  font-size: 13.5px;
  line-height: 1.6;
  max-width: 72ch;
`;

export const StyledMuted = styled.p`
  margin: 0 0 10px;
  font-size: 13px;
  color: ${({ theme }) => theme.colors.muted};
`;

export const StyledKeyPoints = styled.ul`
  margin: 0;
  padding-left: 18px;
  font-size: 13px;
  line-height: 1.6;

  li + li {
    margin-top: 4px;
  }
`;

export const StyledExerciseList = styled.ul`
  list-style: none;
  margin: 0;
  padding: 0;
`;

export const StyledExerciseRow = styled.li`
  display: flex;
  align-items: center;
  justify-content: space-between;
  gap: 12px;
  padding: 12px 0;
  border-top: 1px solid ${({ theme }) => theme.colors.divider};

  &:first-child {
    border-top: 0;
  }
`;

export const StyledExerciseInfo = styled.div`
  min-width: 0;
`;

export const StyledExerciseTitle = styled.p`
  margin: 0;
  font-size: 13.5px;
  font-weight: 600;
`;

export const StyledExerciseMeta = styled.p`
  margin: 2px 0 0;
  font-size: 12px;
  color: ${({ theme }) => theme.colors.muted};
`;

export const StyledKeyPointsToggle = styled.button`
  min-height: 44px;
  padding: 0;
  border: 0;
  background: transparent;
  color: ${({ theme }) => theme.colors.accent600};
  font-size: 13px;
  font-weight: 700;

  &:focus-visible {
    outline: 2px solid ${({ theme }) => theme.colors.accent};
    outline-offset: 2px;
  }
`;
