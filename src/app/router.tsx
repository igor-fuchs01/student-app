import { Navigate, Route, Routes } from "react-router-dom";
import { LoginPage } from "@features/auth/components/LoginPage";
import { DashboardPage } from "@features/dashboard/components/DashboardPage";
import { ProtectedRoute } from "@app/routes/ProtectedRoute";
import { PublicOnlyRoute } from "@app/routes/PublicOnlyRoute";

export function AppRouter() {
  return (
    <Routes>
      <Route
        path="/login"
        element={
          <PublicOnlyRoute>
            <LoginPage />
          </PublicOnlyRoute>
        }
      />
      <Route
        path="/"
        element={
          <ProtectedRoute>
            <DashboardPage />
          </ProtectedRoute>
        }
      />
      <Route path="*" element={<Navigate to="/" replace />} />
    </Routes>
  );
}
