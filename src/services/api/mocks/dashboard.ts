import type { DashboardData } from "@models/dashboard";

export function buildMockDashboard(): DashboardData {
  return {
    streakDays: 7,
    nextExam: {
      subjectName: "Banco de Dados",
      dateLabel: "Sexta-feira, 18/09",
      note: "Simulado integrado disponível",
      overallPreparation: 72,
      priorities: [
        { id: "er-modeling", topicName: "Modelagem ER", level: "high" },
        { id: "normalization", topicName: "Normalização", level: "medium" },
        { id: "basic-sql", topicName: "SQL básico", level: "low" },
      ],
    },
    todayPlan: [
      { id: "review-er-modeling", label: "Revisar Modelagem ER — 20 min", done: false },
      { id: "er-modeling-questions", label: "Fazer 10 questões — Modelagem ER", done: false },
      { id: "review-recent-mistakes", label: "Revisar erros recentes", done: false },
      { id: "mini-quiz", label: "Fazer mini-simulado do assunto", done: true },
    ],
    summaryCards: [
      {
        id: "subjects",
        title: "Disciplinas",
        value: "5 matérias",
        description: "Algoritmos, Arquitetura, SO, TI e Banco de Dados.",
      },
      {
        id: "quizzes",
        title: "Simulados",
        value: "6 disponíveis",
        description: "Um por disciplina, mais o simulado integrado.",
      },
      {
        id: "ranking",
        title: "Ranking",
        value: "7 dias de sequência",
        description: "Baseado em consistência de estudo, não em nota.",
      },
    ],
  };
}
