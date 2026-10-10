import { createBrowserRouter, Navigate } from "react-router-dom";
import { AdminRoute } from "@app/routes/AdminRoute";
import { ProtectedRoute } from "@app/routes/ProtectedRoute";
import { PublicOnlyRoute } from "@app/routes/PublicOnlyRoute";
import { RouteErrorPage } from "@app/routes/RouteErrorPage";
import type { AttemptKindHandle } from "@features/quizzes/hooks/useAttemptKind";

// The exercise lists reuse the simulado attempt screens; the handle tells them which one they are.
const EXERCISE_HANDLE: AttemptKindHandle = { attemptKind: "exercise" };

export const router = createBrowserRouter([
  {
    element: <PublicOnlyRoute />,
    errorElement: <RouteErrorPage />,
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
    errorElement: <RouteErrorPage />,
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
        path: "/disciplinas/:subjectId",
        lazy: () =>
          import("@features/subjects/components/SubjectDetailPage").then(
            ({ SubjectDetailPage }) => ({ Component: SubjectDetailPage }),
          ),
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
        path: "/exercicios",
        lazy: () =>
          import("@features/exercises/components/ExercisesPage").then(({ ExercisesPage }) => ({
            Component: ExercisesPage,
          })),
      },
      {
        path: "/exercicios/:quizId",
        handle: EXERCISE_HANDLE,
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
        path: "/exercicios/:quizId/resultado",
        handle: EXERCISE_HANDLE,
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
  // The admin area has its own login and its own guard, and shares nothing with the student
  // session; its screens are separate chunks, loaded only by who opens /admin.
  {
    path: "/admin/login",
    errorElement: <RouteErrorPage />,
    lazy: () =>
      import("@features/admin/components/AdminLoginPage").then(({ AdminLoginPage }) => ({
        Component: AdminLoginPage,
      })),
  },
  {
    element: <AdminRoute />,
    errorElement: <RouteErrorPage />,
    children: [
      { path: "/admin", element: <Navigate to="/admin/conteudo" replace /> },
      {
        path: "/admin/conteudo",
        lazy: () =>
          import("@features/admin/components/AdminContentPage").then(({ AdminContentPage }) => ({
            Component: AdminContentPage,
          })),
      },
      {
        path: "/admin/questoes",
        lazy: () =>
          import("@features/admin/components/AdminQuestionsPage").then(
            ({ AdminQuestionsPage }) => ({ Component: AdminQuestionsPage }),
          ),
      },
      {
        path: "/admin/questoes/nova",
        lazy: () =>
          import("@features/admin/components/AdminQuestionEditorPage").then(
            ({ AdminQuestionEditorPage }) => ({ Component: AdminQuestionEditorPage }),
          ),
      },
      {
        path: "/admin/questoes/:questionId",
        lazy: () =>
          import("@features/admin/components/AdminQuestionEditorPage").then(
            ({ AdminQuestionEditorPage }) => ({ Component: AdminQuestionEditorPage }),
          ),
      },
      {
        path: "/admin/simulados",
        lazy: () =>
          import("@features/admin/components/AdminQuizzesPage").then(({ AdminQuizzesPage }) => ({
            Component: AdminQuizzesPage,
          })),
      },
      {
        path: "/admin/simulados/novo",
        lazy: () =>
          import("@features/admin/components/AdminQuizEditorPage").then(
            ({ AdminQuizEditorPage }) => ({ Component: AdminQuizEditorPage }),
          ),
      },
      {
        path: "/admin/simulados/importar",
        lazy: () =>
          import("@features/admin/components/AdminQuizImportPage").then(
            ({ AdminQuizImportPage }) => ({ Component: AdminQuizImportPage }),
          ),
      },
      {
        path: "/admin/simulados/:quizId",
        lazy: () =>
          import("@features/admin/components/AdminQuizEditorPage").then(
            ({ AdminQuizEditorPage }) => ({ Component: AdminQuizEditorPage }),
          ),
      },
    ],
  },
  { path: "*", element: <Navigate to="/" replace /> },
]);
