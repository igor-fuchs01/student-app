import { setupWorker } from "msw/browser";
import { handlers } from "./handlers";

/**
 * Starts MSW in the browser: public/mockServiceWorker.js intercepts every
 * request under MOCK_API_BASE_URL and answers it with the handlers.
 * Anything else (page assets, Vite) goes to the network untouched.
 */
export function startMockServer(): Promise<unknown> {
  return setupWorker(...handlers).start({ onUnhandledRequest: "bypass" });
}
