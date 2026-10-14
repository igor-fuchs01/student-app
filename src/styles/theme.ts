export const theme = {
  colorScheme: "light",
  colors: {
    bg: "oklch(98% 0.006 90)",
    surface: "oklch(99.2% 0.004 90)",
    surface2: "oklch(95.5% 0.03 162)",
    surface3: "oklch(96% 0.03 70)",
    text: "oklch(24% 0.015 90)",
    muted: "oklch(48% 0.012 90)",
    divider: "oklch(90% 0.008 90)",
    accent: "oklch(58% 0.13 162)",
    accent600: "oklch(48% 0.135 162)",
    accent100: "oklch(93% 0.05 162)",
    accent2: "oklch(64% 0.13 70)",
    accent2600: "oklch(54% 0.14 70)",
    accent2100: "oklch(93% 0.06 70)",
    danger: "oklch(57% 0.19 27)",
    danger600: "oklch(49% 0.19 27)",
    danger100: "oklch(94% 0.04 27)",
    neutral100: "rgba(0, 0, 0, 0.06)",
  },
  fonts: {
    heading: '"Poppins", system-ui, sans-serif',
    body: '"Inter", system-ui, sans-serif',
  },
  radii: {
    lg: "22px",
    md: "14px",
    pill: "999px",
  },
  shadows: {
    sm: "0 2px 10px rgba(30, 30, 20, 0.06)",
    md: "0 10px 28px rgba(30, 30, 20, 0.1)",
  },
};

export type AppTheme = typeof theme;

export const darkTheme: AppTheme = {
  ...theme,
  colorScheme: "dark",
  colors: {
    bg: "oklch(18% 0.01 90)",
    surface: "oklch(22% 0.012 90)",
    surface2: "oklch(27% 0.04 162)",
    surface3: "oklch(27% 0.04 70)",
    text: "oklch(94% 0.008 90)",
    muted: "oklch(72% 0.012 90)",
    divider: "oklch(32% 0.01 90)",
    accent: "oklch(62% 0.13 162)",
    accent600: "oklch(76% 0.12 162)",
    accent100: "oklch(32% 0.06 162)",
    accent2: "oklch(68% 0.13 70)",
    accent2600: "oklch(80% 0.12 70)",
    accent2100: "oklch(33% 0.06 70)",
    danger: "oklch(62% 0.19 27)",
    danger600: "oklch(74% 0.16 27)",
    danger100: "oklch(32% 0.07 27)",
    neutral100: "rgba(255, 255, 255, 0.1)",
  },
  shadows: {
    sm: "0 2px 10px rgba(0, 0, 0, 0.35)",
    md: "0 10px 28px rgba(0, 0, 0, 0.45)",
  },
};
