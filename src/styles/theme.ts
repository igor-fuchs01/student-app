export const theme = {
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
} as const;

export type AppTheme = typeof theme;
