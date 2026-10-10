import styled from "styled-components";

export const StyledGroup = styled.fieldset`
  border: 1px solid ${({ theme }) => theme.colors.divider};
  border-radius: ${({ theme }) => theme.radii.md};
  padding: 12px 12px 4px;
  margin: 0 0 14px;
  min-width: 0;
`;

export const StyledLegend = styled.legend`
  padding: 0 6px;
  font-size: 12px;
  font-weight: 700;
  color: ${({ theme }) => theme.colors.muted};
`;

export const StyledHint = styled.p`
  margin: 0 0 10px;
  font-size: 12px;
  color: ${({ theme }) => theme.colors.muted};
`;
