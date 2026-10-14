import styled from "styled-components";

export const StyledThemeToggle = styled.button<{ $isDark: boolean }>`
  position: relative;
  width: 52px;
  height: 30px;
  flex-shrink: 0;
  padding: 0;
  border: none;
  border-radius: ${({ theme }) => theme.radii.pill};
  background: ${({ theme, $isDark }) => ($isDark ? theme.colors.accent : theme.colors.divider)};
  transition: background-color 0.25s ease;

  &:focus-visible {
    outline: 2px solid ${({ theme }) => theme.colors.accent600};
    outline-offset: 2px;
  }
`;

export const StyledThumb = styled.span<{ $isDark: boolean }>`
  position: absolute;
  top: 3px;
  left: 3px;
  width: 24px;
  height: 24px;
  display: flex;
  align-items: center;
  justify-content: center;
  border-radius: 50%;
  background: #fff;
  color: ${({ $isDark }) => ($isDark ? "oklch(45% 0.08 260)" : "oklch(70% 0.16 70)")};
  box-shadow: 0 2px 4px rgba(0, 0, 0, 0.25);
  transform: translateX(${({ $isDark }) => ($isDark ? "22px" : "0")});
  transition: transform 0.25s ease;
`;
