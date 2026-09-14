# Melhorias Futuras

Pontos identificados em revisão de código que foram **conscientemente aceitos para o MVP**.
Não são bugs a corrigir agora, mas devem ser tratados antes de o produto sair do MVP.

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
