import { ThemeProvider } from "styled-components";
import { createBrowserRouter, RouterProvider } from "react-router-dom";
import { QueryProvider } from "@app/providers/QueryProvider";
import { AppRouter } from "@app/router";
import { GlobalStyle } from "@styles/GlobalStyle";
import { theme } from "@styles/theme";

const router = createBrowserRouter([{ path: "*", element: <AppRouter /> }]);

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
