import styled from "styled-components";

export const StyledTitle = styled.h1`
  font-family: ${({ theme }) => theme.fonts.heading};
  font-weight: 700;
  font-size: 20px;
  margin: 0 0 4px;
`;

export const StyledSubtitle = styled.p`
  color: ${({ theme }) => theme.colors.muted};
  font-size: 13px;
  margin: 0 0 20px;
`;

export const StyledCountRow = styled.div`
  display: flex;
  gap: 10px;
  margin-bottom: 24px;
  flex-wrap: wrap;
`;

export const StyledFooter = styled.div`
  display: flex;
  justify-content: space-between;
  align-items: center;
  gap: 12px;
  flex-wrap: wrap;
`;

export const StyledConfirmTitle = styled.div`
  font-family: ${({ theme }) => theme.fonts.heading};
  font-weight: 700;
  font-size: 19px;
`;

export const StyledConfirmBody = styled.div`
  font-size: 13.5px;
  color: ${({ theme }) => theme.colors.muted};
  line-height: 1.5;

  strong {
    color: ${({ theme }) => theme.colors.text};
  }
`;

export const StyledConfirmActions = styled.div`
  display: flex;
  justify-content: flex-end;
  gap: 10px;
  margin-top: 6px;
`;

export const StyledErrorMessage = styled.p`
  color: ${({ theme }) => theme.colors.danger600};
  font-size: 12.5px;
  margin: 0;
`;
