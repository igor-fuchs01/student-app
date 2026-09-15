# Melhorias Futuras

Limitações identificadas em revisão de código e evoluções sugeridas pela equipe que foram
**conscientemente deixadas para depois do MVP**. Não são bugs a corrigir agora, mas devem ser
tratadas antes de o produto sair do MVP.

Cada item descreve o problema, por que ele é aceitável hoje e uma proposta de solução.
Ao implementar um item, remova-o daqui e atualize a documentação correspondente.

---

## 1. Persistência da tentativa e cronômetro no servidor

**Problema.** O estado da tentativa (respostas, questões marcadas, questão atual e início do
cronômetro) vive apenas na memória do navegador, em `QuizAttemptLayout`. Um refresh ou o
fechamento da aba descarta todas as respostas e reinicia o cronômetro. O cronômetro também é
controlado somente pelo cliente.

**Por que é aceitável no MVP.** Os simulados são curtos e não há backend real. A regra de
bloqueio de navegação (`useBlocker` + `beforeunload`) reduz o risco de perda acidental.

**Conflita com.** [`02-regras-de-negocio.md`](02-regras-de-negocio.md), seções 3 (cronômetro) e 4
(persistência), e os critérios de "Persistência" em
[`99-criterios-de-aceite-mvp.md`](99-criterios-de-aceite-mvp.md).

**Proposta.**

1. Salvar o estado da tentativa em `src/services/storage/` (localStorage ou IndexedDB), com
   chave por usuário e simulado, a cada alteração de resposta.
2. Restaurar esse estado ao montar `QuizAttemptLayout`. O cronômetro já é calculado a partir
   do instante de início (`startedAt`), então basta persistir esse valor.
3. Criar no backend um recurso de tentativa (`POST /quizzes/:id/attempts` para iniciar,
   `PUT /attempts/:attemptId/answers` para sincronizar), com `startedAt`/`expiresAt` definidos
   pelo servidor e envio idempotente pelo `attemptId`.
4. Indicar visualmente respostas ainda não sincronizadas.

---

## 2. Gabarito enviado ao navegador antes do envio

**Problema.** `GET /quizzes/:id` retorna, junto com as questões, os campos `correctOptionId`,
`correctOptionIds`, `correctTermId`, `explanation` e `referenceAnswer` (`src/types/quizzes.ts`).
Qualquer aluno consegue ver as respostas pelas ferramentas de desenvolvedor do navegador
durante o simulado.

**Por que é aceitável no MVP.** Os simulados são ferramentas de estudo, sem valor de nota
oficial, e hoje só existe o servidor mock.

**Proposta.**

1. Separar o schema da questão em duas formas: uma para responder (sem gabarito) e outra para
   revisar (com gabarito e explicação).
2. `GET /quizzes/:id` passa a retornar apenas a forma sem gabarito.
3. A resposta de `POST /quizzes/:id/attempts` (ou um `GET /attempts/:attemptId/review`) passa a
   trazer o gabarito e as explicações de cada questão, usados pela tela de resultado.
4. É uma **mudança incompatível de contrato** (ver [`04-contratos-de-api.md`](04-contratos-de-api.md),
   seção 1.4) e precisa ser coordenada com o backend.

---

## 3. Testes automatizados

**Problema.** O projeto não tem test runner nem testes.

**Por que é aceitável no MVP.** Build, lint e verificação de tipos rodam na CI e cobrem parte
dos erros; a prioridade atual é fechar os fluxos do MVP.

**Proposta.**

1. Adicionar **Vitest** (integra com a configuração do Vite, sem novo bundler) e
   **Testing Library** para componentes.
2. Criar o script `npm test` e incluí-lo no workflow de CI.
3. Prioridade de cobertura, do mais crítico para o menos:
   - `src/features/quizzes/splitTemplate.ts`;
   - `src/features/quizzes/isQuestionAnswered.ts` e `questionReviewStatus.ts`;
   - `correctMockQuizAttempt` em `src/services/api/mocks/quizzes.ts`;
   - `src/services/api/httpClient.ts` (erros, `401`, validação de schema);
   - fluxo do simulado: responder → revisar → enviar → resultado.

---

## 4. Plano do dia do dashboard copiado para estado local

**Problema.** `DashboardPage` copia `todayPlan` da resposta da API para um `useState` via
`useEffect`. Isso duplica dado do servidor (contra a regra de
[`03-arquitetura-tecnica.md`](03-arquitetura-tecnica.md)) e as marcações se perdem quando a
query é refeita ou a página é recarregada.

**Por que é aceitável no MVP.** Ainda não existe endpoint para persistir as marcações, e o
contrato atual já documenta que elas são apenas locais.

**Proposta.**

1. Criar um endpoint, por exemplo `PATCH /dashboard/plan/:itemId` com `{ "done": boolean }`.
2. Usar `useMutation` com atualização otimista via `queryClient.setQueryData` na query
   `["dashboard", userId]`.
3. Remover o `useState`/`useEffect` e renderizar direto de `dashboardQuery.data.todayPlan`.

---

## 5. Correção de dissertativas no mock

**Problema.** O servidor mock marca uma dissertativa (ou lacuna dissertativa) como correta
quando o texto é idêntico à resposta de referência (ignorando espaços e maiúsculas). Qualquer
outra resposta vira `self_review` (autoavaliação).
[`02-regras-de-negocio.md`](02-regras-de-negocio.md), seção 2.4, define correção **manual** no
MVP, e a seção 6 usa o estado `pending_review`, não `self_review`.

**Por que é aceitável no MVP.** Sem painel de correção para professores, a autoavaliação é a
única forma de o aluno ter retorno imediato sobre dissertativas.

**Proposta.**

1. Quando existir correção manual, dissertativas passam a ficar `pending_review` até serem
   corrigidas, sem correção automática por texto idêntico.
2. Alinhar o nome do estado entre documentação, schema (`src/types/quizzes.ts`) e UI.
3. A tela de resultado continua mostrando o resultado parcial das objetivas enquanto houver
   dissertativas pendentes.

---

## 6. Questões classificadas por assunto para diagnóstico de dificuldades

**Problema.** Hoje cada questão só informa a disciplina (`subjectName` em
`src/types/quizzes.ts`). Com isso, o resultado do simulado mostra o desempenho por
**disciplina** ("Banco de Dados: 50%"), mas não diz **quais conceitos** o aluno está errando
dentro dela. Um aluno que acerta SQL e erra Normalização vê apenas um percentual médio, sem
saber o que estudar.

Há ainda uma inconsistência na UI: a seção da tela de resultado se chama "Desempenho por
assunto", mas os dados exibidos são por disciplina.

**Por que é aceitável no MVP.** O banco de questões ainda é pequeno e curado manualmente, e o
desempenho por disciplina já permite validar o fluxo de simulado → resultado.

**Conflita com.** [`02-regras-de-negocio.md`](02-regras-de-negocio.md): a seção 1 exige que toda
questão esteja amarrada a uma disciplina **e a um assunto**; a seção 8 define o desempenho por
disciplina, assunto e subassunto; e a seção 9 prioriza recomendações pelos assuntos com baixo
desempenho. Também é o que responde à pergunta central do produto
([`01-visao-do-produto.md`](01-visao-do-produto.md)): *"O que você aprendeu e o que ainda
precisa estudar?"*

**Proposta.**

1. **Modelo de dados.** Cadastrar os assuntos (e, opcionalmente, subassuntos) de cada disciplina,
   cada um com `id` estável e nome de exibição. Cada questão passa a referenciar um ou mais
   assuntos. Exemplo em Banco de Dados: "Modelagem ER", "Normalização", "SQL básico",
   "Índices".
2. **Contrato da questão** (mudança aditiva, compatível segundo
   [`04-contratos-de-api.md`](04-contratos-de-api.md), seção 1.4). Adicionar a `Question`:

   ```json
   {
     "topics": [{ "id": "normalization", "name": "Normalização" }]
   }
   ```

3. **Contrato do resultado** (também aditivo). Adicionar a `QuizResult` o desempenho por
   assunto, agrupável por disciplina, e o assunto em cada item de revisão:

   ```json
   {
     "topicPerformance": [
       {
         "subjectName": "Banco de Dados",
         "topicId": "normalization",
         "topicName": "Normalização",
         "correct": 1,
         "total": 3,
         "percent": 33
       }
     ]
   }
   ```

   `QuizReviewItem` ganha `topics` com os mesmos objetos da questão.
4. **Regras de cálculo** (seguem as já usadas em `subjectPerformance`):
   - questões `self_review` ficam fora do cálculo; não respondidas entram no denominador;
   - uma questão com vários assuntos conta em cada um deles;
   - enviar `correct` e `total` junto do percentual, para a UI não apresentar como
     dificuldade um assunto avaliado por uma única questão (ex.: exibir "poucas questões" quando
     `total < 3`).
5. **Tela de resultado.**
   - Renomear a seção atual para "Desempenho por disciplina" e, abaixo de cada disciplina,
     listar os assuntos com barra de progresso e a contagem ("1 de 3 acertos").
   - Destacar os assuntos com menor desempenho em um bloco "O que revisar primeiro", com link
     para os materiais do assunto quando a feature de materiais existir.
   - Mostrar o assunto nos cards de "Questões para revisar" e na revisão da prova.
6. **Dashboard e recomendações.** O histórico de desempenho por assunto alimenta
   `nextExam.priorities` (que já usa `topicName`) e as recomendações da seção 9 de
   [`02-regras-de-negocio.md`](02-regras-de-negocio.md), substituindo os valores fixos do mock.
7. **Mock e documentação.** Classificar as questões de `src/services/api/mocks/quizzes.ts` por
   assunto, calcular `topicPerformance` em `correctMockQuizAttempt` e documentar os novos
   campos em [`04-contratos-de-api.md`](04-contratos-de-api.md).
8. **Privacidade.** O desempenho por assunto é dado acadêmico privado: nunca aparece no ranking
   nem para outros alunos ([`02-regras-de-negocio.md`](02-regras-de-negocio.md), seção 11).

---

## 7. Detalhe da disciplina com assuntos e resumos

**Situação atual.** A tela de Disciplinas (`/disciplinas`) mostra um card por disciplina com
quantidade de materiais, quantidade de questões e percentual de preparo. Os cards não são
clicáveis e não existe tela de detalhe; o card do simulado integrado também não leva a lugar
nenhum.

**Objetivo.** Ao clicar em uma disciplina, o aluno vê os assuntos cobrados nela, cada um com um
resumo curto, para relembrar o conteúdo antes de estudar ou fazer um simulado.

**Por que fica para depois do MVP.** Depende da classificação das questões por assunto (item 6)
e de conteúdo de resumo curado pela equipe, que ainda não existe.

**Proposta.**

1. **Rota e navegação.** Criar `/disciplinas/:subjectId`. Os cards da tela de Disciplinas viram
   links (acessíveis por teclado), e o card do simulado integrado leva para o simulado.
2. **Contrato.** Criar `GET /subjects/:id`, retornando a disciplina e seus assuntos:

   ```json
   {
     "id": "banco-de-dados",
     "name": "Banco de Dados",
     "topics": [
       {
         "id": "normalization",
         "name": "Normalização",
         "summary": "Processo de organizar tabelas para reduzir redundância e anomalias.",
         "keyPoints": ["1FN: valores atômicos", "2FN: sem dependências parciais", "3FN: sem dependências transitivas"],
         "questionsCount": 18,
         "materialsCount": 3,
         "preparationPercent": 40
       }
     ]
   }
   ```

   `summary` e `keyPoints` são texto simples, sem HTML ou Markdown, para não exigir um
   renderizador de conteúdo rico nesta etapa.
3. **Tela.** Cabeçalho com a disciplina e o preparo geral; lista de assuntos em cards
   expansíveis com resumo, pontos-chave, preparo do aluno no assunto (item 6) e ações
   "Praticar questões" e "Ver materiais" (quando as features `study` e `materials` existirem).
   Ordenação padrão: assuntos com menor preparo primeiro.
4. **Conteúdo.** Os resumos são curados pela equipe a partir dos materiais da disciplina
   ([`01-visao-do-produto.md`](01-visao-do-produto.md)) e servem para revisão rápida: não
   substituem o material completo. Deixar isso claro na UI.
5. **Organização do código.** A tela fica em `features/subjects/`; se crescer para materiais e
   estudo guiado, extrair para as features planejadas `materials` e `study`
   ([`03-arquitetura-tecnica.md`](03-arquitetura-tecnica.md)).
