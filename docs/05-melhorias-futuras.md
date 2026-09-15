# Melhorias Futuras

Limitações identificadas em revisão de código e evoluções sugeridas pela equipe que foram
**conscientemente deixadas para depois do MVP**. Não são bugs a corrigir agora, mas devem ser
tratadas antes de o produto sair do MVP.

Cada item descreve o problema, por que ele é aceitável hoje e uma proposta de solução.
Ao implementar um item, remova-o daqui e atualize a documentação correspondente. Os números
dos itens são estáveis, porque outros documentos os referenciam: não renumere os demais.

## Índice

| # | Melhoria | Tipo | Depende de |
|---|---|---|---|
| 1 | [Persistência da tentativa e cronômetro no servidor](#1-persistência-da-tentativa-e-cronômetro-no-servidor) | Limitação técnica | Backend |
| 2 | [Gabarito enviado ao navegador antes do envio](#2-gabarito-enviado-ao-navegador-antes-do-envio) | Segurança | Backend |
| 3 | [Testes automatizados](#3-testes-automatizados) | Qualidade | — |
| 4 | [Plano do dia do dashboard copiado para estado local](#4-plano-do-dia-do-dashboard-copiado-para-estado-local) | Limitação técnica | Backend |
| 5 | [Correção de dissertativas no mock](#5-correção-de-dissertativas-no-mock) | Regra de negócio | Painel de correção |
| 6 | [Questões classificadas por assunto](#6-questões-classificadas-por-assunto-para-diagnóstico-de-dificuldades) | Produto | Backend |
| 7 | [Detalhe da disciplina com assuntos e resumos](#7-detalhe-da-disciplina-com-assuntos-e-resumos) | Produto | 6 |
| 8 | [Ranking com gráficos e filtros](#8-ranking-com-gráficos-e-filtros) | Produto | Backend |
| 9 | [Dashboards na tela de Início](#9-dashboards-na-tela-de-início) | Produto | 4, 6 |
| 10 | [Logo e identidade da aplicação](#10-logo-e-identidade-da-aplicação) | Identidade visual | Nome do produto |
| 11 | [Design e implementação para mobile](#11-design-e-implementação-para-mobile) | UX | 10 |

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

---

## 8. Ranking com gráficos e filtros

**Situação atual.** A tela de Ranking mostra o perfil do aluno (sequência atual, meta semanal,
questões e simulados) e uma lista ordenada apenas por dias consecutivos de estudo.

**Objetivo.** Permitir comparar outros indicadores de esforço, com gráficos e filtros. Por
exemplo: quantidade de questões respondidas no simulado X por todos os alunos, quantidade no
simulado Y, além dos dias consecutivos.

**Por que fica para depois do MVP.** Exige que o backend agregue a atividade de todos os alunos
por indicador, simulado e período.

**Regra que não pode ser quebrada.** [`02-regras-de-negocio.md`](02-regras-de-negocio.md),
seção 11: o ranking **nunca** usa nota ou desempenho. Os filtros só podem usar os indicadores de
esforço permitidos: streak, streak semanal, questões realizadas, simulados concluídos e dias
estudados. "Questões realizadas" conta questões **respondidas**, nunca acertos ou erros.

**Proposta.**

1. **Filtros.**
   - Indicador: dias consecutivos, questões respondidas, simulados concluídos, dias estudados.
   - Escopo, quando o indicador for "questões respondidas": todos os simulados ou um simulado
     específico.
   - Período: esta semana, este mês ou desde o início.
   - Os filtros ficam na URL (`/ranking?indicador=questoes&simulado=bd-1&periodo=semana`), para o
     aluno poder compartilhar e voltar à mesma visão.
2. **Contrato.** Estender `GET /ranking` com parâmetros opcionais, sem quebrar o uso atual:
   `GET /ranking?metric=questions_answered&quizId=bd-1&period=week`. Cada entrada passa a trazer
   `value` (o número do indicador escolhido) além dos campos atuais.
3. **Gráficos.**
   - Barras horizontais com os primeiros colocados e a posição do aluno destacada, mesmo fora do
     topo.
   - No perfil, a evolução do próprio aluno no indicador escolhido (ex.: questões por dia na
     semana).
   - Começar com barras em CSS/SVG, reaproveitando o padrão do `ProgressBar`. Uma biblioteca de
     gráficos só deve entrar se esses gráficos não bastarem, com justificativa (ver regras de
     dependências no `CLAUDE.md`). O mesmo componente de gráfico serve ao item 9.
4. **Cuidados.**
   - Contar apenas questões de tentativas enviadas, para não incentivar "responder por
     responder".
   - Mostrar os primeiros colocados e a posição do próprio aluno, em vez de expor a lista inteira
     com alunos sem atividade.
   - Os gráficos precisam de alternativa textual (tabela ou `aria-label` com os valores).

---

## 9. Dashboards na tela de Início

**Situação atual.** A tela de Início mostra a próxima prova (com prioridades), o plano do dia e
três cards de resumo com textos prontos enviados pelo servidor (ex.: "5 matérias"). Não há
gráficos nem evolução ao longo do tempo.

**Objetivo.** Transformar a Início em um painel que responda *"o que eu devo estudar hoje e como
estou evoluindo?"*, seguindo o histórico definido em
[`02-regras-de-negocio.md`](02-regras-de-negocio.md), seção 10, com gráficos simples e legíveis.

**Por que fica para depois do MVP.** Os dados de evolução dependem do histórico de tentativas no
backend, do plano do dia persistido (item 4) e do desempenho por assunto (item 6).

**Proposta.**

1. **Widgets, em ordem de prioridade.**
   1. **O que revisar agora:** os 3 assuntos com menor desempenho recente (item 6), com acesso
      direto ao detalhe do assunto (item 7).
   2. **Evolução de desempenho:** percentual de acerto por semana nas últimas semanas, geral e
      por disciplina.
   3. **Questões erradas recentemente:** lista curta com link para rever cada questão.
   4. **Constância:** sequência atual e meta semanal (hoje só na tela de Ranking).
2. **Contrato.** Estender `GET /dashboard` de forma aditiva com dados **numéricos**
   (ex.: `weeklyPerformance: [{ weekStart, percent }]`), porque os `summaryCards` atuais trazem
   textos prontos que não servem para gráficos. Os campos atuais continuam existindo durante a
   transição.
3. **Estados vazios.** Um aluno novo, sem tentativas, vê um convite para fazer o primeiro
   simulado em vez de gráficos zerados.
4. **Gráficos.** Usar o mesmo componente de gráfico do item 8, sempre com valores também em
   texto.
5. **Validação.** Antes de implementar, prototipar com a equipe quais widgets realmente mudam o
   que o aluno faz e manter no máximo 4 ou 5 na tela, para não virar um painel poluído.

---

## 10. Logo e identidade da aplicação

**Situação atual.** A marca é o emoji "🎓" seguido de "Student App", repetida em dois lugares
(`AppHeader` e `LoginPage`, cada um com seu próprio `StyledBrand`). O `index.html` não define
favicon nem `theme-color`, e o título da aba é "Student App".

**Objetivo.** Criar um logo próprio e aplicá-lo de forma consistente na aplicação.

**Por que fica para depois do MVP.** Não afeta o funcionamento; depende de uma decisão de marca.

**Proposta.**

1. **Decidir o nome antes do logo.** "Student App" é genérico; vale definir se será o nome
   final.
2. **Briefing para o design.**
   - Conceito: preparação, progresso e constância, alinhado a
     [`01-visao-do-produto.md`](01-visao-do-produto.md).
   - Cores a partir do tema atual (`accent` verde e `accent2` laranja em `src/styles/theme.ts`).
   - Precisa ser legível em 16×16 px (favicon).
   - Versões: símbolo, horizontal (símbolo e nome) e monocromática.
3. **Entregáveis.** SVG do logo, `favicon.svg`, PNG de 32 px e de 180 px (atalho no iOS) e
   imagem para compartilhamento em redes sociais.
4. **Implementação.**
   - Arquivos em `public/` (favicons) e `src/assets/` (logo usado nos componentes).
   - Um único componente de marca em `src/components/layout/`, substituindo os dois
     `StyledBrand` duplicados, com texto alternativo acessível.
   - Atualizar o `index.html`: favicon, `theme-color` e título.

---

## 11. Design e implementação para mobile

**Situação atual.** A aplicação foi pensada para desktop, com adaptações pontuais:

- só há breakpoints fixos (`860px` e `640px`) repetidos em vários arquivos de estilo, sem token
  no tema;
- a lista de simulados é uma tabela com `min-width: 640px`, que exige rolagem horizontal, e o
  botão "Iniciar" muda de estilo só no `:hover` da linha;
- a barra lateral de questões (resposta e revisão da prova) tem largura fixa de `320px`;
- alguns alvos de toque têm 26–32 px, abaixo dos 44 px recomendados;
- o drag and drop usa a API HTML5, que não funciona em telas de toque (existe a alternativa de
  tocar no termo e depois na lacuna, mas ela não é destacada como a forma principal no mobile).

**Objetivo.** Ter um design pensado para celular e implementá-lo, principalmente no fluxo de
simulado, que é onde o aluno passa mais tempo.

**Por que fica para depois do MVP.** A prioridade atual é validar os fluxos. Uma boa experiência
mobile exige primeiro um design dedicado.

**Proposta.**

1. **Design antes do código.** Prototipar as telas em largura de 360 px, na ordem:
   1. responder questão;
   2. revisão e resultado;
   3. lista de simulados;
   4. Início;
   5. Disciplinas;
   6. Ranking;
   7. login.
2. **Padrões a definir no design.**
   - Navegação principal em barra inferior no mobile.
   - No simulado: cronômetro e progresso fixos no topo, "Voltar/Avançar" fixos no rodapé e a
     grade de questões em uma gaveta (bottom sheet).
   - Lista de simulados em cards em vez de tabela.
3. **Tokens.** Adicionar `breakpoints` ao tema (`src/styles/theme.ts`) e trocar os valores fixos
   de `@media` por eles.
4. **Acessibilidade e toque.**
   - Alvos de toque com no mínimo 44 px.
   - Nenhuma ação que dependa só de `:hover`.
   - No drag and drop, "tocar no termo e depois na lacuna" como interação principal em telas de
     toque.
   - Respeitar as áreas seguras do iPhone (`env(safe-area-inset-*)`).
5. **Critérios de aceite.** Todas as telas utilizáveis em 360 px sem rolagem horizontal, fluxo
   completo de simulado feito só com toque, e verificação em Chrome (Android) e Safari (iOS).
6. **Documentação.** O índice de [`docs/README.md`](README.md) diz que
   [`03-arquitetura-tecnica.md`](03-arquitetura-tecnica.md) cobre responsividade, mas essa seção
   não existe. Criá-la com os breakpoints e padrões definidos aqui.
