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

export const StyledTimeUpNotice = styled.div`
  display: flex;
  flex-direction: column;
  align-items: flex-start;
  gap: 10px;
  margin-bottom: 20px;
  padding: 14px 18px;
  border-radius: ${({ theme }) => theme.radii.md};
  background: ${({ theme }) => theme.colors.accent2100};
  color: ${({ theme }) => theme.colors.accent2600};
  font-size: 13.5px;
  font-weight: 600;

  p {
    margin: 0;
  }
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

  @media (max-width: ${({ theme }) => theme.breakpoints.sm}) {
    flex-direction: column-reverse;
    align-items: stretch;
  }
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

  @media (max-width: ${({ theme }) => theme.breakpoints.sm}) {
    flex-direction: column-reverse;
    align-items: stretch;
  }
`;

export const StyledErrorMessage = styled.p`
  color: ${({ theme }) => theme.colors.danger600};
  font-size: 12.5px;
  margin: 0;
`;
