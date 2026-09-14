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
            staleTime: 5 * 60_000,
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
