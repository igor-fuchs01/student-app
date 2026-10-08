import styled from "styled-components";

export const StyledPanel = styled.section`
  display: flex;
  flex-direction: column;
  min-width: 0;
  padding: 24px 28px 28px;
  background: ${({ theme }) => theme.colors.surface};
  border-radius: ${({ theme }) => theme.radii.lg};
  box-shadow: ${({ theme }) => theme.shadows.sm};

  @media (max-width: ${({ theme }) => theme.breakpoints.sm}) {
    padding: 18px;
  }
`;

export const StyledBackButton = styled.button`
  display: none;
  align-self: flex-start;
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

export const StyledHeader = styled.div`
  display: flex;
  flex-wrap: wrap;
  align-items: baseline;
  gap: 6px 14px;
`;

export const StyledLessonName = styled.h2`
  margin: 0;
  font-family: ${({ theme }) => theme.fonts.heading};
  font-size: 22px;
  font-weight: 700;
  line-height: 1.3;
`;

export const StyledProgress = styled.p`
  margin: 0;
  font-size: 13px;
  color: ${({ theme }) => theme.colors.muted};

  strong {
    color: ${({ theme }) => theme.colors.accent600};
  }
`;

export const StyledTabList = styled.div`
  display: flex;
  gap: 24px;
  margin-top: 16px;
  border-bottom: 1px solid ${({ theme }) => theme.colors.divider};
`;

export const StyledTab = styled.button<{ $active: boolean }>`
  min-height: 44px;
  margin-bottom: -1px;
  padding: 0;
  border: 0;
  border-bottom: 2px solid
    ${({ theme, $active }) => ($active ? theme.colors.accent600 : "transparent")};
  background: transparent;
  color: ${({ theme, $active }) => ($active ? theme.colors.accent600 : theme.colors.muted)};
  font-size: 13.5px;
  font-weight: 600;

  span {
    font-weight: 500;
    color: ${({ theme }) => theme.colors.muted};
  }

  &:hover {
    color: ${({ theme }) => theme.colors.accent600};
  }

  &:focus-visible {
    outline: 2px solid ${({ theme }) => theme.colors.accent};
    outline-offset: 2px;
  }
`;

export const StyledTabPanel = styled.div`
  margin-top: 20px;
`;

export const StyledExerciseGrid = styled.ul`
  display: grid;
  grid-template-columns: repeat(auto-fill, minmax(220px, 1fr));
  gap: 12px;
  list-style: none;
  margin: 0;
  padding: 0;
`;

export const StyledExerciseCard = styled.li`
  display: flex;
  flex-direction: column;
  align-items: flex-start;
  gap: 10px;
  padding: 16px;
  border: 1px solid ${({ theme }) => theme.colors.divider};
  border-radius: ${({ theme }) => theme.radii.md};

  &:hover {
    border-color: ${({ theme }) => theme.colors.accent};
  }
`;

export const StyledExerciseTop = styled.div`
  display: flex;
  align-items: center;
  justify-content: space-between;
  gap: 8px;
  width: 100%;
`;

export const StyledExerciseTitle = styled.p`
  min-width: 0;
  margin: 0;
  font-size: 14px;
  font-weight: 700;
`;

export const StyledExerciseMeta = styled.p`
  margin: 0;
  font-size: 12px;
  color: ${({ theme }) => theme.colors.muted};
`;

export const StyledSummary = styled.p`
  margin: 0 0 16px;
  font-size: 14px;
  line-height: 1.65;
  max-width: 72ch;
`;

export const StyledMuted = styled.p`
  margin: 0 0 16px;
  font-size: 13px;
  color: ${({ theme }) => theme.colors.muted};
`;

export const StyledKeyPointsTitle = styled.h3`
  margin: 0 0 8px;
  font-size: 13px;
  font-weight: 700;
`;

export const StyledKeyPoints = styled.ul`
  margin: 0;
  padding-left: 18px;
  font-size: 13.5px;
  line-height: 1.7;
  max-width: 72ch;

  li + li {
    margin-top: 4px;
  }
`;
