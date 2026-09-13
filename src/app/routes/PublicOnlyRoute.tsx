import type { ReactElement } from "react";
import { Navigate } from "react-router-dom";
import { useAuthStore } from "@features/auth/store/useAuthStore";

type PublicOnlyRouteProps = {
  children: ReactElement;
};

export function PublicOnlyRoute({ children }: PublicOnlyRouteProps) {
  const status = useAuthStore((state) => state.status);

  if (status === "authenticated") {
    return <Navigate to="/" replace />;
  }

  return children;
}
