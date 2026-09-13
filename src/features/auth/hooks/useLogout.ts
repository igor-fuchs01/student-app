import { useNavigate } from "react-router-dom";
import { useAuthStore } from "@features/auth/store/useAuthStore";

export function useLogout(): () => Promise<void> {
  const navigate = useNavigate();
  const logout = useAuthStore((state) => state.logout);

  return async function handleLogout() {
    await logout();
    navigate("/login", { replace: true });
  };
}
