export const API_ENDPOINTS = {
  auth: {
    login: "/auth/login",
    logout: "/auth/logout",
  },
  dashboard: "/dashboard",
  subjects: "/subjects",
  ranking: "/ranking",
  quizzes: {
    list: "/quizzes",
    detail: (id: string) => `/quizzes/${id}`,
    submitAttempt: (id: string) => `/quizzes/${id}/attempts`,
  },
} as const;
