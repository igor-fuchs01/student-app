import styled from "styled-components";

export const StyledHiddenTitle = styled.h1`
  position: absolute;
  width: 1px;
  height: 1px;
  overflow: hidden;
  clip: rect(0 0 0 0);
  white-space: nowrap;
`;

// Lessons on the left and the chosen lesson on the right; on narrow screens only one of them is
// shown, the lesson once the student picked one.
export const StyledLayout = styled.div<{ $showLesson: boolean }>`
  display: grid;
  grid-template-columns: 300px minmax(0, 1fr);
  gap: 22px;
  align-items: start;

  @media (max-width: ${({ theme }) => theme.breakpoints.md}) {
    grid-template-columns: minmax(0, 1fr);

    > :first-child {
      display: ${({ $showLesson }) => ($showLesson ? "none" : "flex")};
    }

    > :last-child {
      display: ${({ $showLesson }) => ($showLesson ? "flex" : "none")};
    }
  }
`;
