import { QueryClient, QueryClientProvider } from "@tanstack/react-query";
import type { ReactNode } from "react";
import { useEffect, useState } from "react";
import { useAuthStore } from "@features/auth/store/useAuthStore";

export function QueryProvider({ children }: { children: ReactNode }) {
  const [client] = useState(
    () =>
      new QueryClient({
        defaultOptions: {
          queries: {
            retry: 1,
            // Entering a page mounts its component: navigating to it, coming back to it
            // or reloading the tab. Every mount asks the API for that page's data again,
            // so what the student reads is never a cached copy of an earlier visit.
            refetchOnMount: "always",
            // Bringing the tab back to the front is not entering a page, so it doesn't refetch.
            refetchOnWindowFocus: false,
          },
        },
      }),
  );

  useEffect(
    () =>
      useAuthStore.subscribe((state, previousState) => {
        if (previousState.status === "authenticated" && state.status !== "authenticated") {
          client.clear();
        }
      }),
    [client],
  );

  return <QueryClientProvider client={client}>{children}</QueryClientProvider>;
}
