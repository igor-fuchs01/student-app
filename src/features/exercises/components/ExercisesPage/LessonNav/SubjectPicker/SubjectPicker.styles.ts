import styled from "styled-components";

export const StyledPicker = styled.div`
  position: relative;
  display: flex;
  flex-direction: column;
  gap: 6px;
`;

export const StyledLabel = styled.span`
  font-size: 11px;
  font-weight: 700;
  letter-spacing: 0.05em;
  text-transform: uppercase;
  color: ${({ theme }) => theme.colors.muted};
`;

// The chosen subject is the context of everything below, so it stands out as the heaviest element.
export const StyledTrigger = styled.button`
  display: flex;
  align-items: center;
  justify-content: space-between;
  gap: 12px;
  width: 100%;
  min-height: 48px;
  padding: 10px 14px;
  border: 1.5px solid ${({ theme }) => theme.colors.accent};
  border-radius: ${({ theme }) => theme.radii.md};
  background: ${({ theme }) => theme.colors.accent100};
  color: ${({ theme }) => theme.colors.accent600};
  font-family: ${({ theme }) => theme.fonts.heading};
  font-size: 16px;
  font-weight: 700;
  line-height: 1.3;
  text-align: left;

  &:focus-visible {
    outline: 2px solid ${({ theme }) => theme.colors.accent};
    outline-offset: 2px;
  }
`;

export const StyledTriggerText = styled.span`
  min-width: 0;
`;

export const StyledChevron = styled.span<{ $open: boolean }>`
  flex: none;
  width: 12px;
  height: 8px;
  background: currentColor;
  clip-path: polygon(0 0, 100% 0, 50% 100%);
  transform: rotate(${({ $open }) => ($open ? "180deg" : "0deg")});
  transition: transform 0.15s ease;
`;

export const StyledListbox = styled.ul`
  position: absolute;
  top: calc(100% + 6px);
  left: 0;
  right: 0;
  z-index: 10;
  max-height: 320px;
  overflow-y: auto;
  list-style: none;
  margin: 0;
  padding: 6px;
  background: ${({ theme }) => theme.colors.surface};
  border: 1px solid ${({ theme }) => theme.colors.divider};
  border-radius: ${({ theme }) => theme.radii.md};
  box-shadow: ${({ theme }) => theme.shadows.md};

  &:focus {
    outline: none;
  }
`;

export const StyledOption = styled.li<{ $active: boolean; $selected: boolean }>`
  display: flex;
  align-items: center;
  gap: 10px;
  min-height: 44px;
  padding: 8px 10px;
  border-radius: 10px;
  cursor: pointer;
  font-size: 14px;
  font-weight: ${({ $selected }) => ($selected ? 700 : 600)};
  line-height: 1.35;
  background: ${({ theme, $active }) => ($active ? theme.colors.accent100 : "transparent")};
  color: ${({ theme, $selected }) => ($selected ? theme.colors.accent600 : theme.colors.text)};
`;

export const StyledOptionName = styled.span`
  flex: 1;
  min-width: 0;
`;

export const StyledOptionCount = styled.span`
  flex: none;
  font-size: 12px;
  font-weight: 500;
  color: ${({ theme }) => theme.colors.muted};
  font-variant-numeric: tabular-nums;
`;
