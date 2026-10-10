import { useEffect } from "react";
import { Navigate, Outlet } from "react-router-dom";
import { useQuery, useQueryClient } from "@tanstack/react-query";
import { StatusMessage } from "@components/ui/StatusMessage";
import { adminApi, onAdminSessionLost } from "@services/api/adminApi";
import { USE_MOCKS } from "@services/api/config";
import { ApiError } from "@services/api/errors";

const ADMIN_SESSION_QUERY_KEY = ["admin", "session"];

// Only keeps the admin screens away from who is not an admin; the data is protected by the
// server, which checks the role on every call. Nothing about the role is kept in the browser:
// each visit asks the server whether the session belongs to an admin.
export function AdminRoute() {
  const queryClient = useQueryClient();
  const session = useQuery({
    queryKey: ADMIN_SESSION_QUERY_KEY,
    queryFn: ({ signal }) => adminApi.getCurrentAdmin(signal),
    enabled: !USE_MOCKS,
    retry: false,
  });

  useEffect(() => {
    onAdminSessionLost(() =>
      queryClient.invalidateQueries({ queryKey: ADMIN_SESSION_QUERY_KEY, exact: true }),
    );
    return () => onAdminSessionLost(null);
  }, [queryClient]);

  if (USE_MOCKS) {
    return (
      <StatusMessage message="A área de administração não está disponível no modo de demonstração." />
    );
  }

  if (session.isError) {
    const refused =
      session.error instanceof ApiError &&
      (session.error.status === 401 || session.error.status === 403);
    if (refused) return <Navigate to="/admin/login" replace />;

    return (
      <StatusMessage
        message="Não foi possível verificar o acesso."
        error={session.error}
        action={{ label: "Tentar novamente", onClick: () => session.refetch() }}
      />
    );
  }

  if (!session.data) return <StatusMessage message="Verificando acesso…" />;

  return <Outlet />;
}
