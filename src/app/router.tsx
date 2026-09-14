import { Navigate, Route, Routes } from "react-router-dom";
import { LoginPage } from "@features/auth/components/LoginPage";
import { DashboardPage } from "@features/dashboard/components/DashboardPage";
import { SubjectsPage } from "@features/subjects/components/SubjectsPage";
import { QuizzesPage } from "@features/quizzes/components/QuizzesPage";
import { QuizAttemptLayout } from "@features/quizzes/components/QuizAttemptLayout";
import { QuizAnsweringPage } from "@features/quizzes/components/QuizAnsweringPage";
import { QuizReviewPage } from "@features/quizzes/components/QuizReviewPage";
import { QuizResultPage } from "@features/quizzes/components/QuizResultPage";
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
      <Route
        path="/disciplinas"
        element={
          <ProtectedRoute>
            <SubjectsPage />
          </ProtectedRoute>
        }
      />
      <Route
        path="/simulados"
        element={
          <ProtectedRoute>
            <QuizzesPage />
          </ProtectedRoute>
        }
      />
      <Route
        path="/simulados/:quizId"
        element={
          <ProtectedRoute>
            <QuizAttemptLayout />
          </ProtectedRoute>
        }
      >
        <Route index element={<QuizAnsweringPage />} />
        <Route path="revisao" element={<QuizReviewPage />} />
      </Route>
      <Route
        path="/simulados/:quizId/resultado"
        element={
          <ProtectedRoute>
            <QuizResultPage />
          </ProtectedRoute>
        }
      />
      <Route path="*" element={<Navigate to="/" replace />} />
    </Routes>
  );
}
