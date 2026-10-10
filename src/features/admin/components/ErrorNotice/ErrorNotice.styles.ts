import styled from "styled-components";

export const StyledErrorNotice = styled.p`
  margin: 0 0 16px;
  font-size: 13px;
  color: ${({ theme }) => theme.colors.danger600};
  background: ${({ theme }) => theme.colors.danger100};
  border-radius: ${({ theme }) => theme.radii.md};
  padding: 10px 12px;
  white-space: pre-line;
`;
