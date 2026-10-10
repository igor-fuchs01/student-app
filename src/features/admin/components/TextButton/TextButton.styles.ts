import styled from "styled-components";

export type TextButtonTone = "accent" | "danger";

export const StyledTextButton = styled.button<{ $tone: TextButtonTone }>`
  min-height: 44px;
  padding: 0 8px;
  border: 0;
  border-radius: ${({ theme }) => theme.radii.md};
  background: transparent;
  color: ${({ theme, $tone }) =>
    $tone === "danger" ? theme.colors.danger600 : theme.colors.accent600};
  font-size: 12.5px;
  font-weight: 700;

  &:hover:not(:disabled) {
    text-decoration: underline;
  }

  &:disabled {
    opacity: 0.5;
    cursor: not-allowed;
  }

  &:focus-visible {
    outline: 2px solid ${({ theme }) => theme.colors.accent};
    outline-offset: 1px;
  }
`;
