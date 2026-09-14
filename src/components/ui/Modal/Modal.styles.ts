import styled from "styled-components";
import { Card } from "@components/ui/Card";

export const StyledOverlay = styled.div`
  position: fixed;
  inset: 0;
  display: grid;
  place-items: center;
  background: rgba(20, 20, 15, 0.45);
  padding: 16px;
  z-index: 100;
`;

export const StyledModalCard = styled(Card)`
  width: min(420px, 100%);
  display: flex;
  flex-direction: column;
  gap: 14px;
`;
