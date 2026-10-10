import styled from "styled-components";

export const StyledOption = styled.div`
  display: flex;
  align-items: center;
  gap: 8px;
  margin-bottom: 8px;
`;

export const StyledCorrect = styled.input`
  flex-shrink: 0;
  width: 20px;
  height: 20px;
  margin: 0 4px;
  accent-color: ${({ theme }) => theme.colors.accent};
`;

export const StyledText = styled.input`
  flex: 1;
  min-width: 0;
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
`;
