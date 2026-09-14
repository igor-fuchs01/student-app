import { Navigate, Outlet } from "react-router-dom";
import { useAuthStore } from "@features/auth/store/useAuthStore";

export function PublicOnlyRoute() {
  const status = useAuthStore((state) => state.status);

  if (status === "authenticated") {
    return <Navigate to="/" replace />;
  }

  return <Outlet />;
}
