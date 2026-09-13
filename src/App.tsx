import { ThemeProvider } from "styled-components";
import { BrowserRouter } from "react-router-dom";
import { QueryProvider } from "@app/providers/QueryProvider";
import { AppRouter } from "@app/router";
import { GlobalStyle } from "@styles/GlobalStyle";
import { theme } from "@styles/theme";

export function App() {
  return (
    <ThemeProvider theme={theme}>
      <GlobalStyle />
      <QueryProvider>
        <BrowserRouter>
          <AppRouter />
        </BrowserRouter>
      </QueryProvider>
    </ThemeProvider>
  );
}
