import styled from "styled-components";

export const StyledPageTitle = styled.h1`
  font-family: ${({ theme }) => theme.fonts.heading};
  font-weight: 700;
  font-size: 20px;
  margin: 0 0 4px;
`;

export const StyledPageSubtitle = styled.p`
  color: ${({ theme }) => theme.colors.muted};
  font-size: 13px;
  margin: 0 0 20px;
  max-width: 640px;
`;

export const StyledAddressField = styled.div`
  max-width: 560px;
  margin-bottom: 16px;

  /* 16 px on phones, so Safari (iOS) does not zoom in when the field gets focus. */
  @media (max-width: ${({ theme }) => theme.breakpoints.sm}) {
    input {
      font-size: 16px;
    }
  }
`;

export const StyledAddressNote = styled.p`
  color: ${({ theme }) => theme.colors.muted};
  font-size: 12px;
  line-height: 1.5;
  margin: -6px 0 0;
`;

export const StyledGrid = styled.div`
  display: grid;
  grid-template-columns: repeat(3, 1fr);
  gap: 16px;
  margin-top: 12px;

  @media (max-width: ${({ theme }) => theme.breakpoints.md}) {
    grid-template-columns: 1fr;
  }
`;
