import { useThemeStore } from "@styles/useThemeStore";
import { StyledThemeToggle, StyledThumb } from "./ThemeToggle.styles";

function SunIcon() {
  return (
    <svg
      viewBox="0 0 24 24"
      width="14"
      height="14"
      fill="none"
      stroke="currentColor"
      strokeWidth="2"
      strokeLinecap="round"
      aria-hidden="true"
    >
      <circle cx="12" cy="12" r="4" fill="currentColor" />
      <path d="M12 2v2M12 20v2M2 12h2M20 12h2M4.9 4.9l1.4 1.4M17.7 17.7l1.4 1.4M4.9 19.1l1.4-1.4M17.7 6.3l1.4-1.4" />
    </svg>
  );
}

function MoonIcon() {
  return (
    <svg viewBox="0 0 24 24" width="14" height="14" fill="currentColor" aria-hidden="true">
      <path d="M20 14.5A8 8 0 0 1 9.5 4a8 8 0 1 0 10.5 10.5Z" />
    </svg>
  );
}

export function ThemeToggle() {
  const mode = useThemeStore((state) => state.mode);
  const toggleMode = useThemeStore((state) => state.toggleMode);
  const isDark = mode === "dark";

  return (
    <StyledThemeToggle
      type="button"
      role="switch"
      onClick={toggleMode}
      aria-checked={isDark}
      aria-label="Modo escuro"
      title={isDark ? "Ativar modo claro" : "Ativar modo escuro"}
      $isDark={isDark}
    >
      <StyledThumb $isDark={isDark}>{isDark ? <MoonIcon /> : <SunIcon />}</StyledThumb>
    </StyledThemeToggle>
  );
}
