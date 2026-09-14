import { createGlobalStyle } from "styled-components";

export const GlobalStyle = createGlobalStyle`
  * {
    box-sizing: border-box;
  }

  html,
  body,
  #root {
    height: 100%;
  }

  body {
    margin: 0;
    font-family: ${({ theme }) => theme.fonts.body};
    background: ${({ theme }) => theme.colors.bg};
    color: ${({ theme }) => theme.colors.text};
    line-height: 1.5;
  }

  h1,
  h2,
  h3,
  h4,
  h5 {
    font-family: ${({ theme }) => theme.fonts.heading};
  }

  input,
  select,
  button {
    font: inherit;
  }

  button {
    cursor: pointer;
  }
`;
