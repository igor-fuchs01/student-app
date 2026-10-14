import { ThemeProvider } from "styled-components";
import { RouterProvider } from "react-router-dom";
import { QueryProvider } from "@app/providers/QueryProvider";
import { router } from "@app/router";
import { GlobalStyle } from "@styles/GlobalStyle";
import { darkTheme, theme } from "@styles/theme";
import { useThemeStore } from "@styles/useThemeStore";

export function App() {
  const mode = useThemeStore((state) => state.mode);

  return (
    <ThemeProvider theme={mode === "dark" ? darkTheme : theme}>
      <GlobalStyle />
      <QueryProvider>
        <RouterProvider router={router} />
      </QueryProvider>
    </ThemeProvider>
  );
}
