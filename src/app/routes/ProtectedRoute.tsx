import type { ReactElement } from "react";
import { Navigate } from "react-router-dom";
import { useAuthStore } from "@features/auth/store/useAuthStore";

type ProtectedRouteProps = {
  children: ReactElement;
};

export function ProtectedRoute({ children }: ProtectedRouteProps) {
  const status = useAuthStore((state) => state.status);

  if (status !== "authenticated") {
    return <Navigate to="/login" replace />;
  }

  return children;
}
