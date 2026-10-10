import styled from "styled-components";

export const StyledItem = styled.div`
  border-bottom: 1px dashed ${({ theme }) => theme.colors.divider};
  margin-bottom: 12px;
`;
