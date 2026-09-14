import styled from "styled-components";

export const StyledAnswerComparison = styled.div`
  display: flex;
  flex-direction: column;
  gap: 10px;
  margin-top: 8px;
  padding-top: 8px;
  border-top: 1px solid ${({ theme }) => theme.colors.divider};
`;

export const StyledAnswerLabel = styled.div`
  font-size: 11px;
  font-weight: 700;
  text-transform: uppercase;
  letter-spacing: 0.04em;
  color: ${({ theme }) => theme.colors.muted};
  margin-bottom: 4px;
`;

export const StyledAnswerText = styled.p`
  font-size: 13px;
  margin: 0;
`;
