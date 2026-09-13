import type { Subject } from "@models/subjects";

export function buildMockSubjects(): Subject[] {
  return [
    {
      id: "algoritmos",
      name: "Algoritmos",
      shortLabel: "AL",
      materialsCount: 14,
      questionsCount: 96,
      preparationPercent: 74,
    },
    {
      id: "arquitetura-computadores",
      name: "Arquitetura de Computadores",
      shortLabel: "AC",
      materialsCount: 10,
      questionsCount: 70,
      preparationPercent: 61,
    },
    {
      id: "sistemas-operacionais",
      name: "Introdução a Sistemas Operacionais",
      shortLabel: "SO",
      materialsCount: 9,
      questionsCount: 58,
      preparationPercent: 68,
    },
    {
      id: "tecnologia-informacao",
      name: "Tecnologia da Informação",
      shortLabel: "TI",
      materialsCount: 11,
      questionsCount: 64,
      preparationPercent: 80,
    },
    {
      id: "banco-de-dados",
      name: "Banco de Dados",
      shortLabel: "BD",
      materialsCount: 12,
      questionsCount: 84,
      preparationPercent: 72,
    },
  ];
}
