import type { QuizAnswer, QuizDetail, QuizResult, QuizSummary, Question } from "@models/quizzes";

const INTEGRATED_QUIZ_ID = "integrado";

const INTEGRATED_QUESTIONS: Question[] = [
  {
    type: "multiple_choice",
    id: "q1",
    subjectName: "Banco de Dados",
    prompt:
      "Em um modelo entidade-relacionamento, qual construção representa uma associação de cardinalidade muitos-para-muitos entre duas entidades?",
    options: [
      { id: "q1-o1", text: "Uma chave estrangeira única na entidade mais fraca" },
      { id: "q1-o2", text: "Uma entidade associativa com chaves das duas entidades" },
      { id: "q1-o3", text: "Um atributo multivalorado em qualquer das entidades" },
      { id: "q1-o4", text: "Uma generalização entre as duas entidades" },
    ],
    correctOptionId: "q1-o2",
    explanation:
      "Associações muitos-para-muitos são resolvidas com uma entidade associativa (tabela de junção) que carrega as chaves estrangeiras das duas entidades originais.",
  },
  {
    type: "multiple_choice",
    id: "q2",
    subjectName: "Banco de Dados",
    prompt: "O que caracteriza a terceira forma normal (3FN) de uma tabela relacional?",
    options: [
      { id: "q2-o1", text: "Todos os atributos possuem valores atômicos" },
      {
        id: "q2-o2",
        text: "Não há dependências parciais de atributos não-chave em relação à chave primária",
      },
      {
        id: "q2-o3",
        text: "Não há dependências transitivas entre atributos não-chave e a chave primária",
      },
      { id: "q2-o4", text: "A tabela possui apenas uma chave candidata" },
    ],
    correctOptionId: "q2-o3",
    explanation:
      "A 3FN exige estar na 2FN e eliminar dependências transitivas: nenhum atributo não-chave pode depender de outro atributo não-chave.",
  },
  {
    type: "single_choice",
    id: "q3",
    subjectName: "Banco de Dados",
    template:
      "Em um banco relacional, o comando {{cmd1}} é usado para inserir novos registros, enquanto o comando {{cmd2}} altera valores de registros já existentes.",
    blanks: [
      {
        id: "cmd1",
        options: [
          { id: "q3-cmd1-insert", text: "INSERT INTO" },
          { id: "q3-cmd1-update", text: "UPDATE" },
          { id: "q3-cmd1-select", text: "SELECT" },
        ],
        correctOptionId: "q3-cmd1-insert",
      },
      {
        id: "cmd2",
        options: [
          { id: "q3-cmd2-update", text: "UPDATE" },
          { id: "q3-cmd2-delete", text: "DELETE FROM" },
          { id: "q3-cmd2-select", text: "SELECT" },
        ],
        correctOptionId: "q3-cmd2-update",
      },
    ],
    explanation:
      "INSERT INTO cria novas linhas; UPDATE modifica linhas existentes; SELECT apenas consulta dados sem alterá-los.",
  },
  {
    type: "multiple_choice",
    id: "q4",
    subjectName: "Arquitetura de Computadores",
    prompt: "Qual é a função da unidade de controle no ciclo de instrução da CPU?",
    options: [
      { id: "q4-o1", text: "Executar operações aritméticas e lógicas sobre os dados" },
      { id: "q4-o2", text: "Armazenar temporariamente os dados durante o processamento" },
      {
        id: "q4-o3",
        text: "Gerar os sinais que coordenam a busca, decodificação e execução das instruções",
      },
      { id: "q4-o4", text: "Armazenar permanentemente o conjunto de instruções do programa" },
    ],
    correctOptionId: "q4-o3",
    explanation:
      "A unidade de controle (UC) coordena o ciclo de instrução, gerando os sinais de controle para busca, decodificação e execução — os cálculos em si ficam a cargo da ULA.",
  },
  {
    type: "multiple_choice",
    id: "q5",
    subjectName: "Algoritmos",
    prompt:
      "Qual é a complexidade de tempo, no pior caso, do algoritmo de busca binária em um vetor ordenado de n elementos?",
    options: [
      { id: "q5-o1", text: "O(1)" },
      { id: "q5-o2", text: "O(log n)" },
      { id: "q5-o3", text: "O(n)" },
      { id: "q5-o4", text: "O(n log n)" },
    ],
    correctOptionId: "q5-o2",
    explanation:
      "A busca binária descarta metade do espaço de busca a cada comparação, resultando em complexidade O(log n).",
  },
  {
    type: "multiple_answer",
    id: "q7",
    subjectName: "Algoritmos",
    prompt: "Quais das estruturas abaixo são exemplos de estruturas de dados lineares?",
    options: [
      { id: "q7-o1", text: "Pilha" },
      { id: "q7-o2", text: "Fila" },
      { id: "q7-o3", text: "Árvore binária" },
      { id: "q7-o4", text: "Grafo" },
      { id: "q7-o5", text: "Lista encadeada" },
    ],
    correctOptionIds: ["q7-o1", "q7-o2", "q7-o5"],
    explanation:
      "Pilha, fila e lista encadeada organizam elementos em sequência linear; árvores e grafos são estruturas não-lineares (hierárquicas ou em rede).",
  },
  {
    type: "drag_and_drop",
    id: "q8",
    subjectName: "Arquitetura de Computadores",
    template:
      "No ciclo de instrução da CPU, a etapa de {{slot1}} lê a instrução da memória; em seguida, a etapa de {{slot2}} interpreta o que deve ser feito, e por fim a etapa de {{slot3}} grava o resultado.",
    terms: [
      { id: "q8-t-fetch", text: "busca (fetch)" },
      { id: "q8-t-decode", text: "decodificação" },
      { id: "q8-t-execute", text: "execução" },
      { id: "q8-t-writeback", text: "escrita (write-back)" },
    ],
    slots: [
      { id: "slot1", correctTermId: "q8-t-fetch" },
      { id: "slot2", correctTermId: "q8-t-decode" },
      { id: "slot3", correctTermId: "q8-t-execute" },
    ],
    explanation:
      "O ciclo de instrução segue busca (fetch) → decodificação → execução; a escrita do resultado (write-back) acontece depois, quando aplicável — por isso não entra em nenhuma lacuna aqui.",
  },
  {
    type: "essay",
    id: "q6",
    subjectName: "Banco de Dados",
    prompt:
      "Explique a diferença entre um índice clusterizado e um índice não-clusterizado em um banco de dados relacional, dando um exemplo de uso para cada um.",
    maxLength: 600,
    referenceAnswer:
      "Um índice clusterizado determina a ordem física dos dados na tabela e só pode haver um por tabela — geralmente a chave primária. Um índice não-clusterizado mantém uma estrutura separada de ponteiros para as linhas e pode haver vários por tabela, como um índice em 'email' para acelerar buscas sem alterar a ordem física dos dados.",
  },
  {
    type: "essay_blanks",
    id: "q9",
    subjectName: "Banco de Dados",
    prompt:
      "Complete a consulta SQL que busca o registro com id igual a 1 na tabela tabelaExemplo:",
    template: "SELECT * {{b1}} tabelaExemplo {{b2}} id = 1;",
    blanks: [
      { id: "b1", referenceAnswer: "FROM" },
      { id: "b2", referenceAnswer: "WHERE" },
    ],
  },
];

export function buildMockQuizList(): QuizSummary[] {
  return [
    {
      id: INTEGRATED_QUIZ_ID,
      title: "Simulado integrado",
      subjectScope: "all",
      questionCount: INTEGRATED_QUESTIONS.length,
      durationMinutes: 15,
      attemptsRemaining: 2,
      difficulty: "medium",
    },
    {
      id: "algoritmos-1",
      title: "Algoritmos — Simulado 1",
      subjectScope: "single",
      subjectName: "Algoritmos",
      questionCount: 15,
      durationMinutes: 30,
      attemptsRemaining: 3,
      difficulty: "medium",
    },
    {
      id: "arquitetura-1",
      title: "Arquitetura — Simulado 1",
      subjectScope: "single",
      subjectName: "Arquitetura de Computadores",
      questionCount: 12,
      durationMinutes: 25,
      attemptsRemaining: 3,
      difficulty: "easy",
    },
    {
      id: "so-1",
      title: "Sistemas Operacionais — Simulado 1",
      subjectScope: "single",
      subjectName: "Sistemas Operacionais",
      questionCount: 15,
      durationMinutes: 30,
      attemptsRemaining: 3,
      difficulty: "medium",
    },
    {
      id: "ti-1",
      title: "Tecnologia da Informação — Simulado 1",
      subjectScope: "single",
      subjectName: "Tecnologia da Informação",
      questionCount: 12,
      durationMinutes: 25,
      attemptsRemaining: 3,
      difficulty: "easy",
    },
    {
      id: "bd-1",
      title: "Banco de Dados — Simulado 1",
      subjectScope: "single",
      subjectName: "Banco de Dados",
      questionCount: 20,
      durationMinutes: 40,
      attemptsRemaining: 3,
      difficulty: "hard",
    },
  ];
}

export function getMockQuizDetail(id: string): QuizDetail | undefined {
  if (id !== INTEGRATED_QUIZ_ID) return undefined;

  return {
    id: INTEGRATED_QUIZ_ID,
    title: "Simulado integrado",
    durationMinutes: 15,
    questions: INTEGRATED_QUESTIONS,
  };
}

function excerpt(text: string, maxLength = 90): string {
  if (text.length <= maxLength) return text;
  return `${text.slice(0, maxLength - 1).trimEnd()}…`;
}

function templateToPlainText(template: string): string {
  return template.replace(/\{\{\w+\}\}/g, "___");
}

function questionPromptExcerpt(question: Question): string {
  if (question.type === "single_choice" || question.type === "drag_and_drop") {
    return excerpt(templateToPlainText(question.template));
  }
  if (question.type === "essay_blanks") {
    return excerpt(`${question.prompt} ${templateToPlainText(question.template)}`);
  }
  return excerpt(question.prompt);
}

function normalizeAnswerText(text: string): string {
  return text.trim().toLowerCase().replace(/\s+/g, " ");
}

export function correctMockQuizAttempt(id: string, answers: QuizAnswer[]): QuizResult | undefined {
  if (id !== INTEGRATED_QUIZ_ID) return undefined;

  const answerByQuestionId = new Map(answers.map((answer) => [answer.questionId, answer]));

  let correctCount = 0;
  let incorrectCount = 0;
  let unansweredCount = 0;
  let selfReviewCount = 0;
  const reviewItems: QuizResult["reviewItems"] = [];
  const subjectTotals = new Map<string, { correct: number; total: number }>();

  for (const question of INTEGRATED_QUESTIONS) {
    const answer = answerByQuestionId.get(question.id);

    if (question.type === "essay") {
      const studentAnswer = answer?.text?.trim();
      if (!studentAnswer) {
        unansweredCount += 1;
      } else if (
        normalizeAnswerText(studentAnswer) === normalizeAnswerText(question.referenceAnswer)
      ) {
        correctCount += 1;
        const subjectTotal = subjectTotals.get(question.subjectName) ?? { correct: 0, total: 0 };
        subjectTotal.total += 1;
        subjectTotal.correct += 1;
        subjectTotals.set(question.subjectName, subjectTotal);
      } else {
        selfReviewCount += 1;
        reviewItems.push({
          questionId: question.id,
          subjectName: question.subjectName,
          promptExcerpt: questionPromptExcerpt(question),
          status: "self_review",
          studentAnswer,
          referenceAnswer: question.referenceAnswer,
        });
      }
      continue;
    }

    if (question.type === "essay_blanks") {
      const blankAnswers = answer?.blankAnswers ?? {};
      const allFilled = question.blanks.every((blank) => blankAnswers[blank.id]?.trim());
      const allMatch = question.blanks.every(
        (blank) =>
          normalizeAnswerText(blankAnswers[blank.id] ?? "") ===
          normalizeAnswerText(blank.referenceAnswer),
      );

      if (!allFilled) {
        unansweredCount += 1;
      } else if (allMatch) {
        correctCount += 1;
        const subjectTotal = subjectTotals.get(question.subjectName) ?? { correct: 0, total: 0 };
        subjectTotal.total += 1;
        subjectTotal.correct += 1;
        subjectTotals.set(question.subjectName, subjectTotal);
      } else {
        const fillTemplate = (valueFor: (blankId: string) => string) =>
          question.template.replace(/\{\{(\w+)\}\}/g, (_, blankId: string) => valueFor(blankId));
        selfReviewCount += 1;
        reviewItems.push({
          questionId: question.id,
          subjectName: question.subjectName,
          promptExcerpt: questionPromptExcerpt(question),
          status: "self_review",
          studentAnswer: fillTemplate((blankId) => blankAnswers[blankId] ?? "___"),
          referenceAnswer: fillTemplate(
            (blankId) =>
              question.blanks.find((blank) => blank.id === blankId)?.referenceAnswer ?? "___",
          ),
        });
      }
      continue;
    }

    let isAnswered: boolean;
    let isCorrect: boolean;

    if (question.type === "multiple_choice") {
      isAnswered = Boolean(answer?.optionId);
      isCorrect = answer?.optionId === question.correctOptionId;
    } else if (question.type === "multiple_answer") {
      const selected = answer?.optionIds ?? [];
      isAnswered = selected.length > 0;
      const selectedSet = new Set(selected);
      const correctSet = new Set(question.correctOptionIds);
      isCorrect =
        isAnswered &&
        selectedSet.size === correctSet.size &&
        [...selectedSet].every((optionId) => correctSet.has(optionId));
    } else if (question.type === "single_choice") {
      const blankAnswers = answer?.blankAnswers ?? {};
      isAnswered = question.blanks.every((blank) => Boolean(blankAnswers[blank.id]));
      isCorrect = question.blanks.every(
        (blank) => blankAnswers[blank.id] === blank.correctOptionId,
      );
    } else {
      const slotAnswers = answer?.slotAnswers ?? {};
      isAnswered = question.slots.every((slot) => Boolean(slotAnswers[slot.id]));
      isCorrect = question.slots.every((slot) => slotAnswers[slot.id] === slot.correctTermId);
    }

    const subjectTotal = subjectTotals.get(question.subjectName) ?? { correct: 0, total: 0 };
    subjectTotal.total += 1;

    if (!isAnswered) {
      unansweredCount += 1;
    } else if (isCorrect) {
      correctCount += 1;
      subjectTotal.correct += 1;
    } else {
      incorrectCount += 1;
      reviewItems.push({
        questionId: question.id,
        subjectName: question.subjectName,
        promptExcerpt: questionPromptExcerpt(question),
        status: "incorrect",
        explanation: question.explanation,
      });
    }

    subjectTotals.set(question.subjectName, subjectTotal);
  }

  const gradedTotal = correctCount + incorrectCount + unansweredCount;
  const scorePercent = gradedTotal > 0 ? Math.round((correctCount / gradedTotal) * 100) : 0;

  const subjectPerformance = Array.from(subjectTotals.entries()).map(([subjectName, totals]) => ({
    subjectName,
    percent: totals.total > 0 ? Math.round((totals.correct / totals.total) * 100) : 0,
  }));

  return {
    quizId: id,
    submittedAt: new Date().toISOString(),
    correctCount,
    incorrectCount,
    unansweredCount,
    selfReviewCount,
    scorePercent,
    subjectPerformance,
    reviewItems,
  };
}
