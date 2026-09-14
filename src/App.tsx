import { ThemeProvider } from "styled-components";
import { RouterProvider } from "react-router-dom";
import { QueryProvider } from "@app/providers/QueryProvider";
import { router } from "@app/router";
import { GlobalStyle } from "@styles/GlobalStyle";
import { theme } from "@styles/theme";

export function App() {
  return (
    <ThemeProvider theme={theme}>
      <GlobalStyle />
      <QueryProvider>
        <RouterProvider router={router} />
      </QueryProvider>
    </ThemeProvider>
  );
}
