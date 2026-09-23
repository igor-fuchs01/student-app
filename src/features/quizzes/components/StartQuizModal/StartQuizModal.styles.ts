import styled, { css } from "styled-components";

export const StyledTitle = styled.div`
  font-family: ${({ theme }) => theme.fonts.heading};
  font-weight: 700;
  font-size: 19px;
`;

export const StyledBody = styled.p`
  font-size: 13.5px;
  color: ${({ theme }) => theme.colors.muted};
  line-height: 1.5;
  margin: 0;
`;

export const StyledOptionList = styled.div`
  display: flex;
  flex-direction: column;
  gap: 10px;
`;

export const StyledOptionLabel = styled.label<{ $selected?: boolean }>`
  display: flex;
  align-items: flex-start;
  gap: 10px;
  padding: 12px 14px;
  border-radius: ${({ theme }) => theme.radii.md};
  font-size: 13px;
  cursor: pointer;

  ${({ theme, $selected }) =>
    $selected
      ? css`
          border: 1.5px solid ${theme.colors.accent};
          background: ${theme.colors.accent100};
        `
      : css`
          border: 1.5px solid ${theme.colors.divider};
        `}

  input {
    margin-top: 2px;
    width: 16px;
    height: 16px;
    accent-color: ${({ theme }) => theme.colors.accent};
  }
`;

export const StyledOptionText = styled.span`
  display: flex;
  flex-direction: column;
  gap: 2px;
`;

export const StyledOptionHint = styled.span`
  color: ${({ theme }) => theme.colors.muted};
  font-size: 11.5px;
`;

export const StyledActions = styled.div`
  display: flex;
  justify-content: flex-end;
  gap: 10px;
  margin-top: 6px;

  @media (max-width: ${({ theme }) => theme.breakpoints.sm}) {
    flex-direction: column-reverse;
    align-items: stretch;
  }
`;
