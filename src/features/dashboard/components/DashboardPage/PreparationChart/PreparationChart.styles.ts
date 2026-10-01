import styled from "styled-components";

export const StyledBars = styled.div`
  position: relative;
  height: 100%;
  display: flex;
  flex-direction: column;
  justify-content: center;
  gap: 18px;
`;

export const StyledBarRow = styled.div`
  display: flex;
  flex-direction: column;
  gap: 4px;
  border-radius: 8px;
  outline-offset: 4px;
`;

export const StyledBarName = styled.div`
  display: flex;
  align-items: baseline;
  gap: 8px;
  min-width: 0;
  font-size: 12.5px;
  font-weight: 600;
`;

export const StyledBarLabel = styled.span`
  min-width: 0;
  white-space: nowrap;
  overflow: hidden;
  text-overflow: ellipsis;
`;

export const StyledBarSub = styled.span`
  flex: none;
  font-size: 11px;
  font-weight: 500;
  color: ${({ theme }) => theme.colors.muted};
`;

export const StyledBarTrack = styled.div`
  display: flex;
  align-items: center;
  gap: 10px;
  height: 14px;
`;

export const StyledBarArea = styled.div`
  position: relative;
  flex: 1;
  height: 100%;
  display: flex;
  align-items: center;
  border-left: 1px solid ${({ theme }) => theme.colors.divider};
`;

export const StyledBarFill = styled.div<{ $value: number }>`
  width: ${({ $value }) => $value}%;
  min-width: 2px;
  height: 12px;
  background: ${({ theme }) => theme.colors.accent};
  border-radius: 0 4px 4px 0;

  ${StyledBarRow}:hover &,
  ${StyledBarRow}:focus-visible & {
    background: ${({ theme }) => theme.colors.accent600};
  }
`;

export const StyledBarTarget = styled.div<{ $value: number }>`
  position: absolute;
  top: -2px;
  bottom: -2px;
  left: ${({ $value }) => $value}%;
  border-left: 1px dashed ${({ theme }) => theme.colors.muted};
`;

export const StyledBarValue = styled.span`
  flex: none;
  width: 36px;
  text-align: right;
  font-size: 12.5px;
  font-weight: 700;
  font-variant-numeric: tabular-nums;
`;

export const StyledEmpty = styled.p`
  height: 100%;
  display: grid;
  place-items: center;
  margin: 0;
  color: ${({ theme }) => theme.colors.muted};
  font-size: 13px;
`;
