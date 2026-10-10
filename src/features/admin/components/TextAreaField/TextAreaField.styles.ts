import styled from "styled-components";

export const StyledField = styled.div`
  margin-bottom: 14px;
`;

export const StyledLabel = styled.label`
  display: block;
  font-size: 12px;
  font-weight: 600;
  color: ${({ theme }) => theme.colors.muted};
  margin-bottom: 6px;
`;

export const StyledTextArea = styled.textarea`
  display: block;
  width: 100%;
  min-height: 88px;
  padding: 10px 14px;
  border-radius: ${({ theme }) => theme.radii.md};
  border: 1.5px solid ${({ theme }) => theme.colors.divider};
  background: ${({ theme }) => theme.colors.bg};
  color: ${({ theme }) => theme.colors.text};
  font: inherit;
  resize: vertical;

  &:focus-visible {
    outline: 2px solid ${({ theme }) => theme.colors.accent};
    outline-offset: 1px;
    border-color: ${({ theme }) => theme.colors.accent};
  }
`;

export const StyledHint = styled.p`
  margin: 6px 0 0;
  font-size: 12px;
  color: ${({ theme }) => theme.colors.muted};
`;
