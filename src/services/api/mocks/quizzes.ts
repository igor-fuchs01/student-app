import type {
  Question,
  QuizAnswer,
  QuizDetail,
  QuizResult,
  QuizReviewItem,
  QuizSummary,
} from "@models/quizzes";
import { isQuestionAnswered } from "@features/quizzes/isQuestionAnswered";
import { normalizeAnswerText } from "@features/quizzes/normalizeAnswerText";

type MockQuizDefinition = Omit<QuizSummary, "questionCount">;

type QuestionOutcome = "correct" | "incorrect" | "unanswered" | "self_review";

const QUESTION_BANK: Question[] = [
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
  {
    type: "multiple_choice",
    id: "q10",
    subjectName: "Sistemas Operacionais",
    prompt: "Qual é a principal função do escalonador de processos em um sistema operacional?",
    options: [
      { id: "q10-o1", text: "Gerenciar a alocação de memória virtual" },
      { id: "q10-o2", text: "Decidir qual processo pronto recebe a CPU e por quanto tempo" },
      { id: "q10-o3", text: "Controlar o acesso aos dispositivos de entrada e saída" },
      { id: "q10-o4", text: "Traduzir endereços lógicos em endereços físicos" },
    ],
    correctOptionId: "q10-o2",
    explanation:
      "O escalonador escolhe, entre os processos prontos, qual será executado pela CPU e por quanto tempo, seguindo uma política como FIFO, Round Robin ou prioridade.",
  },
  {
    type: "multiple_answer",
    id: "q11",
    subjectName: "Sistemas Operacionais",
    prompt:
      "Quais das situações abaixo são condições necessárias para a ocorrência de um deadlock?",
    options: [
      { id: "q11-o1", text: "Exclusão mútua" },
      { id: "q11-o2", text: "Posse e espera" },
      { id: "q11-o3", text: "Preempção de recursos" },
      { id: "q11-o4", text: "Espera circular" },
      { id: "q11-o5", text: "Escalonamento Round Robin" },
    ],
    correctOptionIds: ["q11-o1", "q11-o2", "q11-o4"],
    explanation:
      "As condições de Coffman para deadlock são exclusão mútua, posse e espera, não preempção e espera circular. Permitir a preempção de recursos evita o deadlock.",
  },
  {
    type: "multiple_choice",
    id: "q12",
    subjectName: "Tecnologia da Informação",
    prompt: "Na tríade da segurança da informação (CID), o que o pilar da integridade garante?",
    options: [
      { id: "q12-o1", text: "Que a informação esteja disponível sempre que necessário" },
      { id: "q12-o2", text: "Que a informação só seja acessada por pessoas autorizadas" },
      {
        id: "q12-o3",
        text: "Que a informação não seja alterada de forma indevida ou não autorizada",
      },
      { id: "q12-o4", text: "Que a origem da informação possa ser comprovada" },
    ],
    correctOptionId: "q12-o3",
    explanation:
      "A integridade garante que a informação permaneça exata e completa, sem alterações não autorizadas; confidencialidade e disponibilidade são os outros dois pilares.",
  },
  {
    type: "single_choice",
    id: "q13",
    subjectName: "Tecnologia da Informação",
    template:
      "Em redes de computadores, o protocolo {{p1}} traduz nomes de domínio em endereços IP, enquanto o protocolo {{p2}} atribui endereços IP automaticamente aos dispositivos.",
    blanks: [
      {
        id: "p1",
        options: [
          { id: "q13-p1-dns", text: "DNS" },
          { id: "q13-p1-dhcp", text: "DHCP" },
          { id: "q13-p1-http", text: "HTTP" },
        ],
        correctOptionId: "q13-p1-dns",
      },
      {
        id: "p2",
        options: [
          { id: "q13-p2-dhcp", text: "DHCP" },
          { id: "q13-p2-dns", text: "DNS" },
          { id: "q13-p2-ftp", text: "FTP" },
        ],
        correctOptionId: "q13-p2-dhcp",
      },
    ],
    explanation:
      "O DNS resolve nomes (como www.exemplo.com) para endereços IP; o DHCP distribui as configurações de rede, incluindo o endereço IP, automaticamente.",
  },
];

const QUIZZES: MockQuizDefinition[] = [
  {
    id: "integrado",
    title: "Simulado integrado",
    subjectScope: "all",
    durationMinutes: 15,
    attemptsRemaining: 2,
    difficulty: "medium",
  },
  {
    id: "algoritmos-1",
    title: "Algoritmos — Simulado 1",
    subjectScope: "single",
    subjectName: "Algoritmos",
    durationMinutes: 5,
    attemptsRemaining: 3,
    difficulty: "medium",
  },
  {
    id: "arquitetura-1",
    title: "Arquitetura — Simulado 1",
    subjectScope: "single",
    subjectName: "Arquitetura de Computadores",
    durationMinutes: 5,
    attemptsRemaining: 3,
    difficulty: "easy",
  },
  {
    id: "so-1",
    title: "Sistemas Operacionais — Simulado 1",
    subjectScope: "single",
    subjectName: "Sistemas Operacionais",
    durationMinutes: 5,
    attemptsRemaining: 3,
    difficulty: "medium",
  },
  {
    id: "ti-1",
    title: "Tecnologia da Informação — Simulado 1",
    subjectScope: "single",
    subjectName: "Tecnologia da Informação",
    durationMinutes: 5,
    attemptsRemaining: 3,
    difficulty: "easy",
  },
  {
    id: "bd-1",
    title: "Banco de Dados — Simulado 1",
    subjectScope: "single",
    subjectName: "Banco de Dados",
    durationMinutes: 10,
    attemptsRemaining: 3,
    difficulty: "hard",
  },
];

function findQuiz(id: string): MockQuizDefinition | undefined {
  return QUIZZES.find((quiz) => quiz.id === id);
}

function questionsFor(quiz: MockQuizDefinition): Question[] {
  if (quiz.subjectScope === "all") return QUESTION_BANK;
  return QUESTION_BANK.filter((question) => question.subjectName === quiz.subjectName);
}

export function buildMockQuizList(): QuizSummary[] {
  return QUIZZES.map((quiz) => ({ ...quiz, questionCount: questionsFor(quiz).length }));
}

export function getMockQuizDetail(id: string): QuizDetail | undefined {
  const quiz = findQuiz(id);
  if (!quiz) return undefined;

  return {
    id: quiz.id,
    title: quiz.title,
    durationMinutes: quiz.durationMinutes,
    questions: questionsFor(quiz),
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

function gradeQuestion(question: Question, answer: QuizAnswer | undefined): QuestionOutcome {
  if (!answer || !isQuestionAnswered(question, answer)) return "unanswered";

  switch (question.type) {
    case "multiple_choice":
      return answer.optionId === question.correctOptionId ? "correct" : "incorrect";
    case "multiple_answer": {
      const selected = new Set(answer.optionIds);
      const expected = new Set(question.correctOptionIds);
      const matches =
        selected.size === expected.size && [...selected].every((id) => expected.has(id));
      return matches ? "correct" : "incorrect";
    }
    case "single_choice":
      return question.blanks.every(
        (blank) => answer.blankAnswers?.[blank.id] === blank.correctOptionId,
      )
        ? "correct"
        : "incorrect";
    case "drag_and_drop":
      return question.slots.every((slot) => answer.slotAnswers?.[slot.id] === slot.correctTermId)
        ? "correct"
        : "incorrect";
    case "essay":
      return normalizeAnswerText(answer.text ?? "") ===
        normalizeAnswerText(question.referenceAnswer)
        ? "correct"
        : "self_review";
    case "essay_blanks":
      return question.blanks.every(
        (blank) =>
          normalizeAnswerText(answer.blankAnswers?.[blank.id] ?? "") ===
          normalizeAnswerText(blank.referenceAnswer),
      )
        ? "correct"
        : "self_review";
  }
}

function buildReviewItem(
  question: Question,
  answer: QuizAnswer | undefined,
  outcome: QuestionOutcome,
): QuizReviewItem | null {
  const base = {
    questionId: question.id,
    subjectName: question.subjectName,
    promptExcerpt: questionPromptExcerpt(question),
  };

  if (outcome === "incorrect" && "explanation" in question) {
    return { ...base, status: "incorrect", explanation: question.explanation };
  }

  if (outcome !== "self_review") return null;

  if (question.type === "essay") {
    return {
      ...base,
      status: "self_review",
      studentAnswer: answer?.text?.trim(),
      referenceAnswer: question.referenceAnswer,
    };
  }

  if (question.type === "essay_blanks") {
    const fillTemplate = (valueFor: (blankId: string) => string) =>
      question.template.replace(/\{\{(\w+)\}\}/g, (_, blankId: string) => valueFor(blankId));
    return {
      ...base,
      status: "self_review",
      studentAnswer: fillTemplate((blankId) => answer?.blankAnswers?.[blankId] ?? "___"),
      referenceAnswer: fillTemplate(
        (blankId) =>
          question.blanks.find((blank) => blank.id === blankId)?.referenceAnswer ?? "___",
      ),
    };
  }

  return null;
}

export function correctMockQuizAttempt(id: string, answers: QuizAnswer[]): QuizResult | undefined {
  const quiz = findQuiz(id);
  if (!quiz) return undefined;

  const answerByQuestionId = new Map(answers.map((answer) => [answer.questionId, answer]));
  const counts: Record<QuestionOutcome, number> = {
    correct: 0,
    incorrect: 0,
    unanswered: 0,
    self_review: 0,
  };
  const reviewItems: QuizReviewItem[] = [];
  const subjectTotals = new Map<string, { correct: number; total: number }>();

  for (const question of questionsFor(quiz)) {
    const answer = answerByQuestionId.get(question.id);
    const outcome = gradeQuestion(question, answer);
    counts[outcome] += 1;

    const reviewItem = buildReviewItem(question, answer, outcome);
    if (reviewItem) reviewItems.push(reviewItem);

    if (outcome === "self_review") continue;

    const subjectTotal = subjectTotals.get(question.subjectName) ?? { correct: 0, total: 0 };
    subjectTotal.total += 1;
    if (outcome === "correct") subjectTotal.correct += 1;
    subjectTotals.set(question.subjectName, subjectTotal);
  }

  const gradedTotal = counts.correct + counts.incorrect + counts.unanswered;
  const scorePercent = gradedTotal > 0 ? Math.round((counts.correct / gradedTotal) * 100) : 0;

  const subjectPerformance = Array.from(subjectTotals.entries()).map(([subjectName, totals]) => ({
    subjectName,
    percent: Math.round((totals.correct / totals.total) * 100),
  }));

  return {
    quizId: id,
    submittedAt: new Date().toISOString(),
    correctCount: counts.correct,
    incorrectCount: counts.incorrect,
    unansweredCount: counts.unanswered,
    selfReviewCount: counts.self_review,
    scorePercent,
    subjectPerformance,
    reviewItems,
  };
}
