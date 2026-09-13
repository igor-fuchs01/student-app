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

export const StyledInput = styled.input`
  width: 100%;
  min-height: 44px;
  padding: 10px 14px;
  border-radius: ${({ theme }) => theme.radii.md};
  border: 1.5px solid ${({ theme }) => theme.colors.divider};
  background: ${({ theme }) => theme.colors.bg};
  color: ${({ theme }) => theme.colors.text};

  &:focus-visible {
    outline: 2px solid ${({ theme }) => theme.colors.accent};
    outline-offset: 1px;
    border-color: ${({ theme }) => theme.colors.accent};
  }

  &[aria-invalid="true"] {
    border-color: #d92d20;
  }
`;

export const StyledErrorText = styled.p`
  margin: 6px 0 0;
  font-size: 12px;
  color: #d92d20;
`;
