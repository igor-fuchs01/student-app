import { create } from "zustand";
import { persist } from "zustand/middleware";

export type ThemeMode = "light" | "dark";

type ThemeState = {
  mode: ThemeMode;
  toggleMode: () => void;
};

export const useThemeStore = create<ThemeState>()(
  persist(
    (set) => ({
      mode: window.matchMedia("(prefers-color-scheme: dark)").matches ? "dark" : "light",
      toggleMode: () => set(({ mode }) => ({ mode: mode === "dark" ? "light" : "dark" })),
    }),
    { name: "student-app:theme-mode" },
  ),
);
