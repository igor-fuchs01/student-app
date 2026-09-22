import { subjectSchema, type Subject, type SubjectDetail } from "@models/subjects";

const MOCK_SUBJECTS: SubjectDetail[] = [
  {
    id: "algoritmos",
    name: "Algoritmos",
    shortLabel: "AL",
    materialsCount: 9,
    questionsCount: 96,
    preparationPercent: 74,
    topics: [
      {
        id: "logica-de-programacao",
        number: 1,
        name: "Lógica de Programação",
        description:
          "Como descrever a solução de um problema em passos que o computador consegue executar.",
        subtopics: [
          {
            id: "variaveis-e-tipos",
            name: "Variáveis e Tipos de Dados",
            summary:
              "Uma variável é um espaço na memória identificado por um nome; o tipo define quais valores cabem nela e quais operações são válidas.",
            keyPoints: [
              "Tipos primitivos: inteiro, real, caractere e lógico.",
              "O nome identifica o espaço; o valor pode mudar durante a execução.",
              "Converter tipos sem cuidado perde informação, como de real para inteiro.",
            ],
            materials: [
              {
                id: "apostila-logica",
                title: "Apostila — Lógica de programação",
                fileUrl: "/materiais/algoritmos/apostila-logica.pdf",
              },
              {
                id: "slides-tipos-de-dados",
                title: "Slides da aula — Tipos de dados",
                fileUrl: "/materiais/algoritmos/slides-tipos-de-dados.pdf",
              },
            ],
          },
          {
            id: "decisao-e-repeticao",
            name: "Estruturas de Decisão e Repetição",
            summary:
              "As estruturas de controle decidem quais trechos do algoritmo executam e quantas vezes eles se repetem.",
            keyPoints: [
              "A estrutura de decisão escolhe um caminho a partir de uma condição lógica.",
              "O laço com contador repete um número conhecido de vezes; o condicional, enquanto a condição for verdadeira.",
              "Todo laço precisa de uma condição de parada, senão vira um laço infinito.",
            ],
            materials: [
              {
                id: "exercicios-estruturas-de-controle",
                title: "Exercícios — Estruturas de controle",
                fileUrl: "/materiais/algoritmos/exercicios-estruturas-de-controle.pdf",
              },
              {
                id: "lista-resolvida-lacos",
                title: "Lista resolvida — Laços de repetição",
                fileUrl: "/materiais/algoritmos/lista-resolvida-lacos.pdf",
              },
            ],
          },
        ],
      },
      {
        id: "estruturas-de-dados",
        number: 2,
        name: "Estruturas de Dados",
        description:
          "Formas de organizar dados na memória e o custo de inserir, remover e buscar em cada uma delas.",
        subtopics: [
          {
            id: "vetores-e-matrizes",
            name: "Vetores e Matrizes",
            summary:
              "Vetores guardam vários valores do mesmo tipo em posições contíguas, acessadas por um índice.",
            keyPoints: [
              "O índice do primeiro elemento é zero na maioria das linguagens.",
              "O acesso por índice é imediato; inserir no meio exige deslocar os demais.",
              "Uma matriz é um vetor de vetores, percorrido por linha e coluna.",
            ],
            materials: [
              {
                id: "apostila-vetores",
                title: "Apostila — Vetores e matrizes",
                fileUrl: "/materiais/algoritmos/apostila-vetores.pdf",
              },
              {
                id: "exercicios-matrizes",
                title: "Exercícios — Percorrendo matrizes",
                fileUrl: "/materiais/algoritmos/exercicios-matrizes.pdf",
              },
            ],
          },
          {
            id: "listas-pilhas-filas",
            name: "Listas, Pilhas e Filas",
            summary:
              "São estruturas lineares que se diferenciam pela regra de entrada e saída dos elementos.",
            keyPoints: [
              "Pilha segue LIFO: o último a entrar é o primeiro a sair.",
              "Fila segue FIFO: o primeiro a entrar é o primeiro a sair.",
              "A lista encadeada cresce sem realocar, mas não permite acesso direto por índice.",
            ],
            materials: [
              {
                id: "apostila-listas-encadeadas",
                title: "Apostila — Listas encadeadas",
                fileUrl: "/materiais/algoritmos/apostila-listas-encadeadas.pdf",
              },
              {
                id: "slides-pilhas-e-filas",
                title: "Slides da aula — Pilhas e filas",
                fileUrl: "/materiais/algoritmos/slides-pilhas-e-filas.pdf",
              },
              {
                id: "lista-resolvida-estruturas-lineares",
                title: "Lista resolvida — Estruturas lineares",
                fileUrl: "/materiais/algoritmos/lista-resolvida-estruturas-lineares.pdf",
              },
            ],
          },
        ],
      },
    ],
  },
  {
    id: "arquitetura-computadores",
    name: "Arquitetura de Computadores",
    shortLabel: "AC",
    materialsCount: 7,
    questionsCount: 70,
    preparationPercent: 61,
    topics: [
      {
        id: "organizacao-de-computadores",
        number: 1,
        name: "Organização de Computadores",
        description:
          "Os componentes internos de um computador e como eles cooperam para executar um programa.",
        subtopics: [
          {
            id: "arquitetura-von-neumann",
            name: "Arquitetura de Von Neumann",
            summary:
              "No modelo de Von Neumann, programa e dados ficam na mesma memória e a CPU os busca pelo mesmo barramento.",
            keyPoints: [
              "Componentes: unidade de controle, unidade lógica e aritmética, memória e entrada/saída.",
              "Programa armazenado: as instruções ficam na memória, como qualquer outro dado.",
              "O barramento único entre CPU e memória é o gargalo do modelo.",
            ],
            materials: [
              {
                id: "apostila-von-neumann",
                title: "Apostila — Modelo de Von Neumann",
                fileUrl: "/materiais/arquitetura/apostila-von-neumann.pdf",
              },
              {
                id: "slides-componentes-do-computador",
                title: "Slides da aula — Componentes do computador",
                fileUrl: "/materiais/arquitetura/slides-componentes-do-computador.pdf",
              },
            ],
          },
          {
            id: "ciclo-de-instrucao",
            name: "Processador e Ciclo de Instrução",
            summary:
              "O processador repete o ciclo de buscar, decodificar e executar uma instrução por vez.",
            keyPoints: [
              "Busca: o contador de programa aponta a próxima instrução na memória.",
              "Decodificação: a unidade de controle identifica a operação e os operandos.",
              "Pipeline sobrepõe as etapas de instruções diferentes para aumentar a vazão.",
            ],
            materials: [
              {
                id: "apostila-ciclo-de-instrucao",
                title: "Apostila — Ciclo de instrução",
                fileUrl: "/materiais/arquitetura/apostila-ciclo-de-instrucao.pdf",
              },
              {
                id: "exercicios-pipeline",
                title: "Exercícios — Pipeline",
                fileUrl: "/materiais/arquitetura/exercicios-pipeline.pdf",
              },
            ],
          },
        ],
      },
      {
        id: "memoria-e-barramentos",
        number: 2,
        name: "Memória e Barramentos",
        description: "Onde os dados ficam enquanto o programa roda e por onde eles trafegam.",
        subtopics: [
          {
            id: "hierarquia-de-memoria",
            name: "Hierarquia de Memória",
            summary:
              "A memória é organizada em níveis: quanto mais perto do processador, mais rápida, menor e mais cara.",
            keyPoints: [
              "Ordem típica: registradores, cache, memória principal e armazenamento secundário.",
              "A cache explora a localidade temporal e espacial dos acessos.",
              "Um acerto na cache evita o acesso, muito mais lento, à memória principal.",
            ],
            materials: [
              {
                id: "apostila-hierarquia-de-memoria",
                title: "Apostila — Hierarquia de memória",
                fileUrl: "/materiais/arquitetura/apostila-hierarquia-de-memoria.pdf",
              },
              {
                id: "lista-resolvida-cache",
                title: "Lista resolvida — Cache",
                fileUrl: "/materiais/arquitetura/lista-resolvida-cache.pdf",
              },
            ],
          },
          {
            id: "barramentos-e-entrada-e-saida",
            name: "Barramentos e Entrada/Saída",
            summary:
              "Os barramentos ligam processador, memória e periféricos; a entrada e saída pode ser por consulta, interrupção ou acesso direto à memória.",
            keyPoints: [
              "Um barramento tem linhas de dados, de endereço e de controle.",
              "A interrupção evita que a CPU fique consultando o dispositivo em laço.",
              "O DMA transfere blocos entre periférico e memória sem passar pela CPU.",
            ],
            materials: [
              {
                id: "slides-entrada-e-saida",
                title: "Slides da aula — Entrada e saída",
                fileUrl: "/materiais/arquitetura/slides-entrada-e-saida.pdf",
              },
            ],
          },
        ],
      },
    ],
  },
  {
    id: "sistemas-operacionais",
    name: "Introdução a Sistemas Operacionais",
    shortLabel: "SO",
    materialsCount: 7,
    questionsCount: 58,
    preparationPercent: 68,
    topics: [
      {
        id: "processos-e-threads",
        number: 1,
        name: "Processos e Threads",
        description:
          "Como o sistema operacional representa um programa em execução e divide o processador entre vários deles.",
        subtopics: [
          {
            id: "estados-do-processo",
            name: "Estados de um Processo",
            summary:
              "Um processo é um programa em execução com seu próprio espaço de memória, e passa por estados bem definidos até terminar.",
            keyPoints: [
              "Estados principais: pronto, em execução e bloqueado.",
              "Só um processo por núcleo ocupa o estado de execução a cada instante.",
              "Threads de um mesmo processo compartilham memória, mas têm pilha própria.",
            ],
            materials: [
              {
                id: "apostila-processos",
                title: "Apostila — Processos e threads",
                fileUrl: "/materiais/sistemas-operacionais/apostila-processos.pdf",
              },
              {
                id: "slides-estados-do-processo",
                title: "Slides da aula — Estados do processo",
                fileUrl: "/materiais/sistemas-operacionais/slides-estados-do-processo.pdf",
              },
            ],
          },
          {
            id: "escalonamento",
            name: "Escalonamento de Processos",
            summary:
              "O escalonador decide qual processo pronto ocupa o processador e por quanto tempo.",
            keyPoints: [
              "FIFO atende por ordem de chegada e penaliza processos curtos.",
              "Round-robin dá a cada processo uma fatia de tempo fixa.",
              "Escalonamento preemptivo interrompe o processo antes de ele terminar.",
            ],
            materials: [
              {
                id: "exercicios-escalonamento",
                title: "Exercícios — Algoritmos de escalonamento",
                fileUrl: "/materiais/sistemas-operacionais/exercicios-escalonamento.pdf",
              },
              {
                id: "lista-resolvida-round-robin",
                title: "Lista resolvida — Round-robin",
                fileUrl: "/materiais/sistemas-operacionais/lista-resolvida-round-robin.pdf",
              },
            ],
          },
        ],
      },
      {
        id: "gerencia-de-memoria",
        number: 2,
        name: "Gerência de Memória",
        description:
          "Como o sistema operacional divide a memória entre os processos e cria a ilusão de memória infinita.",
        subtopics: [
          {
            id: "memoria-virtual",
            name: "Memória Virtual e Paginação",
            summary:
              "A memória virtual dá a cada processo um espaço de endereços próprio, dividido em páginas que podem estar na RAM ou em disco.",
            keyPoints: [
              "A tabela de páginas traduz endereço virtual em endereço físico.",
              "Uma falta de página busca no disco a página ausente.",
              "A paginação elimina a fragmentação externa da alocação contígua.",
            ],
            materials: [
              {
                id: "apostila-memoria-virtual",
                title: "Apostila — Memória virtual",
                fileUrl: "/materiais/sistemas-operacionais/apostila-memoria-virtual.pdf",
              },
              {
                id: "slides-paginacao",
                title: "Slides da aula — Paginação",
                fileUrl: "/materiais/sistemas-operacionais/slides-paginacao.pdf",
              },
            ],
          },
          {
            id: "substituicao-de-paginas",
            name: "Substituição de Páginas",
            summary:
              "Quando a memória está cheia, o sistema escolhe qual página remover para carregar a que falta.",
            keyPoints: [
              "FIFO remove a página mais antiga, mesmo que ainda seja muito usada.",
              "LRU remove a que ficou mais tempo sem ser acessada.",
              "Thrashing é o estado em que o sistema passa mais tempo trocando páginas do que executando.",
            ],
            materials: [
              {
                id: "exercicios-substituicao-de-paginas",
                title: "Exercícios — Substituição de páginas",
                fileUrl: "/materiais/sistemas-operacionais/exercicios-substituicao-de-paginas.pdf",
              },
            ],
          },
        ],
      },
    ],
  },
  {
    id: "tecnologia-informacao",
    name: "Tecnologia da Informação",
    shortLabel: "TI",
    materialsCount: 8,
    questionsCount: 64,
    preparationPercent: 80,
    topics: [
      {
        id: "fundamentos-de-redes",
        number: 1,
        name: "Fundamentos de Redes",
        description: "Como os computadores se conectam e trocam dados entre si.",
        subtopics: [
          {
            id: "modelo-osi-e-tcp-ip",
            name: "Modelo OSI e TCP/IP",
            summary:
              "Os modelos em camadas separam as responsabilidades da comunicação, da transmissão física até a aplicação.",
            keyPoints: [
              "O modelo OSI tem sete camadas; o TCP/IP agrupa as mesmas funções em quatro.",
              "Cada camada só conversa com a camada equivalente do outro lado.",
              "TCP garante entrega e ordem; UDP é mais rápido e não garante nenhuma das duas.",
            ],
            materials: [
              {
                id: "apostila-modelo-osi",
                title: "Apostila — Modelo OSI",
                fileUrl: "/materiais/tecnologia-informacao/apostila-modelo-osi.pdf",
              },
              {
                id: "slides-tcp-ip",
                title: "Slides da aula — Pilha TCP/IP",
                fileUrl: "/materiais/tecnologia-informacao/slides-tcp-ip.pdf",
              },
            ],
          },
          {
            id: "enderecamento-ip",
            name: "Endereçamento IP",
            summary:
              "O endereço IP identifica um dispositivo na rede e a máscara separa a parte de rede da parte de host.",
            keyPoints: [
              "IPv4 usa 32 bits escritos em quatro octetos decimais.",
              "A máscara de sub-rede define quantos bits identificam a rede.",
              "Endereços privados não são roteáveis na internet e dependem de NAT.",
            ],
            materials: [
              {
                id: "exercicios-subredes",
                title: "Exercícios — Cálculo de sub-redes",
                fileUrl: "/materiais/tecnologia-informacao/exercicios-subredes.pdf",
              },
              {
                id: "lista-resolvida-enderecamento",
                title: "Lista resolvida — Endereçamento IP",
                fileUrl: "/materiais/tecnologia-informacao/lista-resolvida-enderecamento.pdf",
              },
            ],
          },
        ],
      },
      {
        id: "seguranca-da-informacao",
        number: 2,
        name: "Segurança da Informação",
        description: "O que precisa ser protegido em um sistema e quais práticas reduzem o risco.",
        subtopics: [
          {
            id: "principios-da-seguranca",
            name: "Princípios da Segurança",
            summary:
              "Confidencialidade, integridade e disponibilidade são os três pilares que orientam qualquer controle de segurança.",
            keyPoints: [
              "Confidencialidade: só quem tem autorização acessa a informação.",
              "Integridade: a informação não é alterada sem autorização.",
              "Disponibilidade: a informação está acessível quando é necessária.",
            ],
            materials: [
              {
                id: "apostila-principios-seguranca",
                title: "Apostila — Princípios da segurança",
                fileUrl: "/materiais/tecnologia-informacao/apostila-principios-seguranca.pdf",
              },
              {
                id: "slides-ameacas-comuns",
                title: "Slides da aula — Ameaças comuns",
                fileUrl: "/materiais/tecnologia-informacao/slides-ameacas-comuns.pdf",
              },
            ],
          },
          {
            id: "boas-praticas-e-backup",
            name: "Boas Práticas e Backup",
            summary:
              "Controle de acesso, atualização e cópia de segurança são as defesas que mais evitam perda de dados no dia a dia.",
            keyPoints: [
              "Princípio do menor privilégio: cada usuário recebe só o acesso necessário.",
              "A regra 3-2-1 mantém três cópias, em duas mídias, com uma fora do local.",
              "Um backup só existe de verdade depois que a restauração foi testada.",
            ],
            materials: [
              {
                id: "apostila-politica-de-backup",
                title: "Apostila — Política de backup",
                fileUrl: "/materiais/tecnologia-informacao/apostila-politica-de-backup.pdf",
              },
              {
                id: "exercicios-controle-de-acesso",
                title: "Exercícios — Controle de acesso",
                fileUrl: "/materiais/tecnologia-informacao/exercicios-controle-de-acesso.pdf",
              },
            ],
          },
        ],
      },
    ],
  },
  {
    id: "banco-de-dados",
    name: "Banco de Dados",
    shortLabel: "BD",
    materialsCount: 8,
    questionsCount: 84,
    preparationPercent: 72,
    topics: [
      {
        id: "modelagem-conceitual",
        number: 1,
        name: "Fundamentos e Modelagem Conceitual",
        description:
          "Como transformar um problema do mundo real em um modelo entidade-relacionamento.",
        subtopics: [
          {
            id: "modelo-er",
            name: "Modelo Entidade-Relacionamento",
            summary:
              "O modelo ER descreve o domínio em entidades, atributos e relacionamentos, antes de qualquer decisão sobre tabelas.",
            keyPoints: [
              "Entidade: objeto do mundo real com existência própria.",
              "Atributo: característica de uma entidade; a chave identifica cada ocorrência.",
              "Relacionamento: associação entre duas ou mais entidades.",
            ],
            materials: [
              {
                id: "apostila-modelagem-er",
                title: "Apostila — Modelagem ER",
                fileUrl: "/materiais/banco-de-dados/apostila-modelagem-er.pdf",
              },
              {
                id: "slides-introducao-ao-er",
                title: "Slides da aula — Introdução ao ER",
                fileUrl: "/materiais/banco-de-dados/slides-introducao-ao-er.pdf",
              },
            ],
          },
          {
            id: "cardinalidade",
            name: "Cardinalidade e Relacionamentos",
            summary:
              "A cardinalidade define quantas ocorrências de uma entidade podem se associar a ocorrências de outra.",
            keyPoints: [
              "1:1 — a chave estrangeira fica no lado de participação obrigatória.",
              "1:N — a chave estrangeira fica sempre no lado N.",
              "N:N — vira uma entidade associativa com as chaves das duas entidades.",
            ],
            materials: [
              {
                id: "exercicios-cardinalidade",
                title: "Exercícios — Cardinalidade",
                fileUrl: "/materiais/banco-de-dados/exercicios-cardinalidade.pdf",
              },
            ],
          },
        ],
      },
      {
        id: "modelo-relacional-e-normalizacao",
        number: 2,
        name: "Modelo Relacional e Normalização",
        description:
          "Conversão do modelo conceitual para tabelas e as formas normais que eliminam redundância.",
        subtopics: [
          {
            id: "modelo-relacional",
            name: "Modelo Relacional",
            summary:
              "Os dados são organizados em tabelas com chaves primárias e estrangeiras garantindo a integridade referencial.",
            keyPoints: [
              "Chave primária identifica cada tupla de forma única.",
              "Chave estrangeira referencia a chave primária de outra relação.",
              "Integridade referencial impede referências a tuplas inexistentes.",
            ],
            materials: [
              {
                id: "apostila-modelo-relacional",
                title: "Apostila — Modelo relacional",
                fileUrl: "/materiais/banco-de-dados/apostila-modelo-relacional.pdf",
              },
            ],
          },
          {
            id: "normalizacao",
            name: "Normalização",
            summary:
              "Normalizar é decompor tabelas para reduzir redundância e evitar anomalias de inserção, atualização e exclusão.",
            keyPoints: [
              "1FN: todos os valores são atômicos, sem grupos repetitivos.",
              "2FN: 1FN e sem dependências parciais da chave primária.",
              "3FN: 2FN e sem dependências transitivas entre atributos não-chave.",
            ],
            materials: [
              {
                id: "apostila-normalizacao",
                title: "Apostila — Normalização",
                fileUrl: "/materiais/banco-de-dados/apostila-normalizacao.pdf",
              },
              {
                id: "lista-resolvida-formas-normais",
                title: "Lista resolvida — 1FN a 3FN",
                fileUrl: "/materiais/banco-de-dados/lista-resolvida-formas-normais.pdf",
              },
            ],
          },
        ],
      },
      {
        id: "sql",
        number: 3,
        name: "SQL: Definição e Manipulação",
        description:
          "Comandos para criar a estrutura do banco e para consultar e manipular os dados.",
        subtopics: [
          {
            id: "ddl",
            name: "DDL — Definição de Dados",
            summary:
              "A DDL cria e altera a estrutura do banco: tabelas, colunas, restrições e índices.",
            keyPoints: [
              "CREATE TABLE define colunas, tipos e restrições.",
              "ALTER TABLE altera a estrutura sem perder os dados existentes.",
              "Índices aceleram a leitura e têm custo na escrita.",
            ],
            materials: [
              {
                id: "guia-rapido-ddl",
                title: "Guia rápido — DDL",
                fileUrl: "/materiais/banco-de-dados/guia-rapido-ddl.pdf",
              },
            ],
          },
          {
            id: "dml-consultas",
            name: "DML e Consultas",
            summary:
              "A DML manipula os dados: inserir, atualizar, excluir e, principalmente, consultar com SELECT.",
            keyPoints: [
              "SELECT … WHERE filtra linhas antes do agrupamento.",
              "JOIN combina tabelas pela condição de junção.",
              "GROUP BY agrupa linhas e HAVING filtra os grupos.",
            ],
            materials: [
              {
                id: "lista-exercicios-select",
                title: "Lista de exercícios — SELECT",
                fileUrl: "/materiais/banco-de-dados/lista-exercicios-select.pdf",
              },
            ],
          },
        ],
      },
    ],
  },
];

export function buildMockSubjects(): Subject[] {
  return MOCK_SUBJECTS.map((subject) => subjectSchema.parse(subject));
}

export function getMockSubjectDetail(subjectId: string): SubjectDetail | undefined {
  const subject = MOCK_SUBJECTS.find((item) => item.id === subjectId);
  if (!subject) return undefined;

  return { ...subject, topics: [...subject.topics].sort((a, b) => a.number - b.number) };
}
