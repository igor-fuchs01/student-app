import { StrictMode } from "react";
import { createRoot } from "react-dom/client";
import { App } from "./App";

async function startMockServerIfEnabled(): Promise<void> {
  // Compared against the raw env var so production builds drop MSW and the mock data entirely.
  if (import.meta.env.VITE_USE_MOCKS !== "true") return;
  const { startMockServer } = await import("@services/api/mocks/mockServer");
  await startMockServer();
}

startMockServerIfEnabled().then(() => {
  createRoot(document.getElementById("root")!).render(
    <StrictMode>
      <App />
    </StrictMode>,
  );
});
