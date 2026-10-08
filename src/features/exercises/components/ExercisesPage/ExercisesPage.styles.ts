import styled, { type DefaultTheme } from "styled-components";

const fitViewport = ({ theme }: { theme: DefaultTheme }) =>
  `(min-width: ${theme.breakpoints.md}) and (min-height: 560px)`;

export const StyledHiddenTitle = styled.h1`
  position: absolute;
  width: 1px;
  height: 1px;
  overflow: hidden;
  clip: rect(0 0 0 0);
  white-space: nowrap;
`;

// Lessons on the left and the chosen lesson on the right; on narrow screens only one of them is
// shown, the lesson once the student picked one. When the page fits the viewport, both columns
// fill its height and scroll inside instead of the page.
export const StyledLayout = styled.div<{ $showLesson: boolean }>`
  display: grid;
  grid-template-columns: 300px minmax(0, 1fr);
  gap: 22px;
  align-items: start;

  @media ${fitViewport} {
    flex: 1;
    min-height: 0;
    grid-template-rows: minmax(0, 1fr);
    align-items: stretch;
  }

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
