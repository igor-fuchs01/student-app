import { createBrowserRouter, Navigate } from "react-router-dom";
import { ProtectedRoute } from "@app/routes/ProtectedRoute";
import { PublicOnlyRoute } from "@app/routes/PublicOnlyRoute";

export const router = createBrowserRouter([
  {
    element: <PublicOnlyRoute />,
    children: [
      {
        path: "/login",
        lazy: () =>
          import("@features/auth/components/LoginPage").then(({ LoginPage }) => ({
            Component: LoginPage,
          })),
      },
    ],
  },
  {
    element: <ProtectedRoute />,
    children: [
      {
        path: "/",
        lazy: () =>
          import("@features/dashboard/components/DashboardPage").then(({ DashboardPage }) => ({
            Component: DashboardPage,
          })),
      },
      {
        path: "/disciplinas",
        lazy: () =>
          import("@features/subjects/components/SubjectsPage").then(({ SubjectsPage }) => ({
            Component: SubjectsPage,
          })),
      },
      {
        path: "/simulados",
        lazy: () =>
          import("@features/quizzes/components/QuizzesPage").then(({ QuizzesPage }) => ({
            Component: QuizzesPage,
          })),
      },
      {
        path: "/simulados/:quizId",
        lazy: () =>
          import("@features/quizzes/components/QuizAttemptLayout").then(
            ({ QuizAttemptLayout }) => ({ Component: QuizAttemptLayout }),
          ),
        children: [
          {
            index: true,
            lazy: () =>
              import("@features/quizzes/components/QuizAnsweringPage").then(
                ({ QuizAnsweringPage }) => ({ Component: QuizAnsweringPage }),
              ),
          },
          {
            path: "revisao",
            lazy: () =>
              import("@features/quizzes/components/QuizReviewPage").then(({ QuizReviewPage }) => ({
                Component: QuizReviewPage,
              })),
          },
        ],
      },
      {
        path: "/simulados/:quizId/resultado",
        lazy: () =>
          import("@features/quizzes/components/QuizResultPage").then(({ QuizResultPage }) => ({
            Component: QuizResultPage,
          })),
      },
      {
        path: "/ranking",
        lazy: () =>
          import("@features/ranking/components/RankingPage").then(({ RankingPage }) => ({
            Component: RankingPage,
          })),
      },
    ],
  },
  { path: "*", element: <Navigate to="/" replace /> },
]);
