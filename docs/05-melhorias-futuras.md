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
| 5 | [Correção de dissertativas no mock](#5-correção-de-dissertativas-no-mock) | Regra de negócio | Painel de correção |
| 6 | [Questões classificadas por assunto](#6-questões-classificadas-por-assunto-para-diagnóstico-de-dificuldades) | Produto | Backend |
| 7 | [Conteúdo curado do detalhe da disciplina](#7-conteúdo-curado-do-detalhe-da-disciplina) | Limitação técnica | Backend |
| 8 | [Ranking com gráficos e filtros](#8-ranking-com-gráficos-e-filtros) | Produto | Backend |
| 10 | [Logo e identidade da aplicação](#10-logo-e-identidade-da-aplicação) | Identidade visual | Nome do produto |
| 12 | [Correção de dissertativas por IA com chave do aluno](#12-correção-de-dissertativas-por-ia-com-chave-do-aluno) | Produto | — |
| 13 | [Simulados criados pelo próprio aluno](#13-simulados-criados-pelo-próprio-aluno) | Produto | 6 |
| 14 | [Gráficos escolhidos pelo aluno](#14-gráficos-escolhidos-pelo-aluno) | Produto | 8 |
| 15 | [Histórico de provas realizadas](#15-histórico-de-provas-realizadas) | Produto | — |
| 16 | [Endpoints de administração do conteúdo](#16-endpoints-de-administração-do-conteúdo) | Produto | Backend |
| 17 | [Resetar o preparo de um simulado](#17-resetar-o-preparo-de-um-simulado) | Produto | — |

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
oficial. No Supabase, o app não consegue listar tabela nenhuma pela API, mas
a edge function `get-quiz` ainda devolve o gabarito de cada simulado, para seguir o contrato atual.

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

1. **Modelagem de dados.** Cadastrar os assuntos (e, opcionalmente, subassuntos) de cada disciplina,
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
6. **Dashboard e recomendações.** Com várias questões por assunto, as recomendações
   (`studyFocus` em `GET /dashboard`, hoje fora da tela) passam a refletir o desempenho real de
   cada assunto, seguindo as recomendações da seção 9 de [`02-regras-de-negocio.md`](02-regras-de-negocio.md).
7. **Mock e documentação.** Classificar as questões de `src/services/api/mocks/quizzes.ts` por
   assunto, calcular `topicPerformance` em `correctMockQuizAttempt` e documentar os novos
   campos em [`04-contratos-de-api.md`](04-contratos-de-api.md).
8. **Privacidade.** O desempenho por assunto é dado acadêmico privado: nunca aparece no ranking
   nem para outros alunos ([`02-regras-de-negocio.md`](02-regras-de-negocio.md), seção 11).

---

## 7. Conteúdo curado do detalhe da disciplina

**Situação atual.** A tela em `/disciplinas/:subjectId` já é servida pelo banco: a migration
`…_content.sql` traz as tabelas do conteúdo e a edge function `get-subject` devolve o JSON de
`SubjectDetail`
([`04-contratos-de-api.md`](04-contratos-de-api.md), `GET /subjects/:id`). O que falta é conteúdo,
não encanamento: no banco os resumos e os pontos-chave são só os do seed, e os `fileUrl` apontam
para arquivos que não existem.

**Objetivo.** Ter a tela com os resumos curados pela equipe e os PDFs de verdade.

**Por que fica para depois do MVP.** Os resumos e os pontos-chave são conteúdo curado que ainda não
existe, os PDFs não têm onde ficar, e o preparo por subassunto depende da classificação das
questões (item 6).

**Proposta.**

1. **Modelo de dados e função — feitos.** As migrations trazem `subtopics` (assunto, nome, resumo,
   ordem) e `subtopic_key_points`, dá a `topics` o número da aula (único na disciplina) e uma
   descrição e pendura os materiais no subassunto; a edge function `get-subject` monta a tela,
   chamada pelo adaptador `supabaseSubjectsApi.getSubject`.
2. **Arquivos dos materiais.** Hoje `fileUrl` aponta para caminhos que não existem. Definir onde os
   PDFs ficam (Supabase Storage).
3. **Preparo por subassunto.** Com as questões classificadas (item 6), incluir o preparo do aluno em
   cada subassunto e permitir ordenar a lista lateral pelos mais fracos primeiro. O rótulo continua
   vindo de `number`, então reordenar não renumera as aulas.
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
     dependências no `CLAUDE.md`). Os gráficos em SVG da tela de Início
     (`src/features/dashboard/components/DashboardPage/`) são o ponto de partida.
4. **Cuidados.**
   - Contar apenas questões de tentativas enviadas, para não incentivar "responder por
     responder".
   - Mostrar os primeiros colocados e a posição do próprio aluno, em vez de expor a lista inteira
     com alunos sem atividade.
   - Os gráficos precisam de alternativa textual (tabela ou `aria-label` com os valores).

---

## 10. Logo e identidade da aplicação

**Situação atual.** O logo (símbolo do livro com circuito, recortado da arte original em PNG) e
o nome "Student App" ficam no componente `Brand` (`src/components/layout/Brand/`), usado no
`AppHeader` e na `LoginPage`: o símbolo dentro de um quadrado arredondado, "Student" em verde
escuro (`theme.colors.brand`) e "App" em verde claro (`theme.colors.brandAccent`). O símbolo fica
em `src/assets/logo-mark.png`; o `index.html` define o favicon (`public/favicon-32.png`), o ícone
de atalho no iOS (`public/apple-touch-icon.png`) e o `theme-color`.

**Objetivo.** Concluir a identidade visual: o que falta é decidir o nome final, ter o logo em
SVG (inclusive `favicon.svg`) e em versão monocromática, e a imagem para redes sociais.

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
4. **Implementação.** Trocar `src/assets/logo-mark.png` pelo SVG no componente `Brand`, adicionar
   `public/favicon.svg` ao `index.html` e, se o nome mudar, atualizar o `Brand` e o título.

---

## 12. Correção de dissertativas por IA com chave do aluno

**Situação atual.** Uma dissertativa (ou lacuna dissertativa) diferente da resposta de referência
vira `self_review`: o aluno compara a própria resposta com a referência e se autoavalia (item 5).
Ele não recebe nenhum retorno sobre *o que* acertou ou deixou de fora.

**Objetivo.** Ao final da prova, uma IA corrige as dissertativas e explica o que está certo e o que
faltou, usando uma chave de API que o próprio aluno configura. O recurso não depende de um
provedor específico: qualquer serviço de IA que aceite chamadas com chave de API serve.

**Por que fica para depois do MVP.** O MVP define a correção de dissertativas como manual, e a
correção por IA como uma evolução posterior.

**Conflita com.** [`02-regras-de-negocio.md`](02-regras-de-negocio.md), seção 2.4 (correção
assistida por IA só depois da implementação manual), e
[`99-criterios-de-aceite-mvp.md`](99-criterios-de-aceite-mvp.md), que coloca IA na Fase 7.

**Decisões já tomadas.**

- **A chave é do aluno e fica só no front-end.** Nenhum servidor do projeto recebe ou guarda a
  chave: o navegador chama a API do provedor diretamente. É a única forma de o sistema nunca ter
  acesso a ela.
- **A correção acontece no final da prova.** Ela roda depois do envio, na tela de resultado, só
  para os itens `self_review`, que já trazem `studentAnswer` e `referenceAnswer`
  ([`04-contratos-de-api.md`](04-contratos-de-api.md), seção 3.14). O contrato com o backend não
  muda.
- **A validação reduzida é um trade-off aceito.** Como a correção roda no navegador, ninguém confere
  o veredito da IA no servidor, e o aluno pode alterar o resultado pelas ferramentas de
  desenvolvedor. É aceitável porque os simulados são ferramentas de estudo sem valor de nota
  oficial e o ranking nunca usa desempenho acadêmico
  ([`02-regras-de-negocio.md`](02-regras-de-negocio.md), seção 11).

**Proposta.**

1. **Configuração da chave.** Uma tela (na feature planejada `profile`) para informar o provedor e o
   modelo, colar a chave, testá-la e removê-la.
   - Por padrão, a chave fica só na memória e some ao recarregar a página. Se for desejável
     lembrá-la durante a sessão, usar `sessionStorage` e deixar essa escolha explícita para o aluno.
   - A chave nunca é enviada ao backend nem aparece em logs.
   - Antes de ativar, avisar que as respostas do aluno saem do sistema para o provedor escolhido,
     sob a conta dele, e pedir consentimento. Os termos de uso de dados de cada provedor são
     responsabilidade do aluno conferir.
   - Orientar o aluno a criar uma chave restrita: só para o serviço de IA, com limite de gasto e,
     quando o provedor permitir, restrição ao domínio da aplicação.
2. **Camada de serviço.** Um módulo em `src/services/` (por exemplo, `services/ai/`) esconde o
   provedor atrás de uma única operação, "corrigir dissertativa", que devolve um veredito. Trocar de
   IA não mexe nas telas. Componentes não chamam a API diretamente
   ([`03-arquitetura-tecnica.md`](03-arquitetura-tecnica.md)). Usar `fetch`, sem SDK de provedor.
3. **Prompt e resposta.**
   - O prompt leva o enunciado, a resposta de referência e a resposta do aluno, com esta última
     claramente delimitada, para reduzir tentativas de manipular a IA pelo texto da resposta.
   - Pedir saída em JSON estruturado, como `{ "verdict": "correct" | "incorrect", "feedback": "..." }`,
     e validá-la com zod, como qualquer resposta de API do projeto.
4. **Resultado.**
   - O veredito substitui a autoavaliação na tela de resultado e na revisão da prova, com a
     explicação da IA e a indicação de que a correção foi feita por IA.
   - Acertos, erros e nota exibidos são recalculados no navegador, e o resultado corrigido fica
     salvo só localmente (`quizAttemptStorage`). Enviá-lo ao backend exigiria um contrato novo e fica
     fora deste item.
5. **Falhas.** Sem chave, chave inválida (`401`/`403`), limite de uso atingido (`429`), falta de
   conexão ou resposta fora do formato esperado: mostrar uma mensagem em português e voltar para a
   autoavaliação manual. O resultado da prova nunca fica bloqueado pela IA.
6. **Mock e testes.** Um handler do MSW que imita a resposta do provedor permite desenvolver e
   testar sem chave real e sem custo.
7. **Documentação.** Ao implementar, atualizar [`02-regras-de-negocio.md`](02-regras-de-negocio.md)
   (seções 2.4 e 6), [`99-criterios-de-aceite-mvp.md`](99-criterios-de-aceite-mvp.md) e
   [`04-contratos-de-api.md`](04-contratos-de-api.md) (seção 5, se o mock ganhar o handler do
   provedor), e remover este item daqui.

---

## 13. Simulados criados pelo próprio aluno

**Situação atual.** Os simulados são fixos e curados pela equipe: existem como linhas em `quizzes`
com as questões escolhidas em `quiz_questions`, e o aluno só escolhe qual fazer na lista de
`GET /quizzes`.

**Objetivo.** O aluno monta o próprio simulado: escolhe a disciplina e os assuntos, quantas questões
quer, a dificuldade e a duração, e o sistema seleciona as questões.

**Por que fica para depois do MVP.** Escolher bem as questões depende da classificação por assunto
(item 6). Antes disso, um simulado montado pelo aluno só conseguiria filtrar por disciplina, que é o
que a lista fixa já faz.

**Proposta.**

1. **Modelo de dados.** `quizzes` ganha o dono do simulado (por exemplo `created_by_student_id`,
   nulo nos oficiais). O RLS passa a permitir que o aluno leia os simulados oficiais e os seus, e
   nunca os de outro aluno ([`06-modelagem-de-dados.md`](06-modelagem-de-dados.md)).
2. **Criação no servidor.** Uma função `create_custom_quiz(p_subject_id, p_topic_ids,
   p_question_count, p_difficulty, p_duration_minutes)` sorteia as questões e grava o simulado. O
   cliente **não** envia a lista de questões: ele só descreve o que quer, e o servidor decide. Isso
   evita que o aluno monte um simulado com questões escolhidas a dedo pelo id.
3. **Contrato** (mudança aditiva, [`04-contratos-de-api.md`](04-contratos-de-api.md), seção 1.4):
   `POST /quizzes` recebe os filtros e devolve o [`QuizSummary`](04-contratos-de-api.md#310-quizsummary)
   criado. `QuizSummary` ganha um campo opcional indicando que o simulado é do aluno, para a UI
   separar "Oficiais" de "Meus simulados".
4. **Regras.**
   - A quantidade pedida é limitada pelas questões que existem nos assuntos escolhidos; se houver
     menos, o simulado é criado com o que existe e a UI avisa.
   - Apagar um simulado próprio só é permitido enquanto ele não tiver tentativas; com tentativas, ele
     é arquivado, para o histórico (item 15) não ficar com buracos.
   - Simulados próprios contam normalmente no desempenho e nos dias de estudo. O ranking continua
     medindo esforço, nunca nota ([`02-regras-de-negocio.md`](02-regras-de-negocio.md), seção 11).
5. **UI.** Botão "Criar simulado" na lista de simulados, com um formulário curto (disciplina,
   assuntos, número de questões, dificuldade e duração) e um resumo antes de confirmar.
6. **Mock.** `handlers.ts` ganha a rota, gerando o simulado a partir do banco de questões do mock.

---

## 14. Gráficos escolhidos pelo aluno

**Situação atual.** A tela de Início tem gráficos fixos (evolução do acerto e preparo por
disciplina), iguais para todo mundo, e o item 8 propõe outros no Ranking.

**Objetivo.** O aluno escolhe quais gráficos quer ver, dentre as opções disponíveis, e em que ordem.
Cada um acompanha o que interessa: evolução por disciplina, questões por dia, assuntos mais errados,
dias de estudo.

**Por que fica para depois do MVP.** Só faz sentido depois que houver gráficos suficientes (item 8) e
que o desempenho por assunto estiver pronto (item 6). Sem isso, não há opções para escolher.

**Proposta.**

1. **Catálogo de gráficos.** Uma lista fechada de gráficos disponíveis, cada um com id estável,
   título e fonte de dados. O aluno escolhe **dentre essas opções**; não existe gráfico livre, para
   nenhuma escolha expor dado que o produto não permite.
2. **Preferências do aluno.** Guardar por aluno quais gráficos estão visíveis e em que posição.
   São dados do próprio aluno: leitura e escrita só das próprias linhas, pelas regras de acesso do
   banco.
3. **Contrato** (aditivo): `GET /me/charts` devolve o catálogo com a escolha atual, e
   `PUT /me/charts` salva a nova seleção.
4. **UI.** Um modo "Personalizar" na tela de Início e no Ranking, com as opções em caixas de
   seleção e ordenação simples. Manter no máximo 4 ou 5 gráficos visíveis, como na tela de
   Início, para a tela não virar um painel poluído.
5. **Regras que não mudam.** Nenhum gráfico pode mostrar nota ou desempenho de outro aluno
   ([`02-regras-de-negocio.md`](02-regras-de-negocio.md), seção 11), e todo gráfico precisa de
   alternativa textual, com os valores acessíveis por leitor de tela.

---

## 15. Histórico de provas realizadas

**Situação atual.** O banco já guarda todas as tentativas (`quiz_attempts` e
`quiz_attempt_answers`), mas o app só mostra o resultado da tentativa que acabou de ser enviada, e
ele vem do `localStorage` (`quizAttemptStorage`). Trocando de navegador ou limpando os dados, o
aluno perde o acesso ao que já fez.

**Objetivo.** Uma tela com todas as provas que o aluno já realizou: data, simulado, nota e acertos,
com a opção de abrir a revisão completa de qualquer uma delas.

**Por que fica para depois do MVP.** O MVP fecha o ciclo com o resultado da prova recém-enviada.
Vale registrar, porém, que [`99-criterios-de-aceite-mvp.md`](99-criterios-de-aceite-mvp.md) lista
"visualizar histórico" como critério de aceite, e
[`02-regras-de-negocio.md`](02-regras-de-negocio.md), seção 10, descreve o histórico como parte do
produto: este item fecha essa lacuna.

**Proposta.**

1. **Contrato** (aditivo): `GET /attempts` devolve a lista das tentativas do aluno (id, simulado,
   data de envio, nota e contadores), da mais recente para a mais antiga; `GET /attempts/:id`
   devolve o [`QuizResult`](04-contratos-de-api.md#314-quizresult) daquela tentativa, com as
   respostas, para reabrir a revisão.
2. **No servidor.** Duas funções de leitura que filtram pelo aluno autenticado. Nenhum aluno enxerga
   tentativa de outro.
3. **Fonte da verdade.** A tela de resultado passa a buscar a tentativa pela API, e o `localStorage`
   deixa de ser o único lugar onde o resultado existe (relacionado ao item 1).
4. **UI.** Nova tela "Histórico", com a lista das tentativas, filtro por disciplina e um resumo da
   evolução da nota. Cada linha abre a revisão da prova, reaproveitando as telas de resultado e de
   revisão que já existem.
5. **Cuidado com o crescimento.** A lista é paginada, porque um aluno pode acumular muitas
   tentativas ao longo do curso.

---

## 16. Endpoints de administração do conteúdo

**Situação atual.** Disciplinas, assuntos, subassuntos, materiais, questões e simulados só entram no
banco por migration, pelo `supabase/seed.sql` ou pelo script de operador
`supabase/scripts/import-quiz.sql`, executado à mão no SQL editor. Toda edge function atende só
alunos: `serveEndpoint` (`supabase/functions/_shared/http.ts`) busca o `auth_user_id` do JWT em
`students` e devolve `401` para qualquer outra conta. Não existe o papel de administrador.

**Objetivo.** Endpoints de administração para cadastrar e editar o conteúdo (questões, assuntos,
disciplinas etc.) sem escrever SQL.

**Por que fica para depois do MVP.** [`99-criterios-de-aceite-mvp.md`](99-criterios-de-aceite-mvp.md)
coloca o painel administrativo na Fase 7. Enquanto uma única pessoa cura o conteúdo, o
`import-quiz.sql` basta e não abre nenhuma superfície nova na API.

**Proposta.**

1. **Papel de administrador.** Marcar quem é admin por uma tabela `admins` (`auth_user_id`) em uma
   migration nova, ou por um claim em `app_metadata` do Supabase Auth, que só o service role altera.
   As contas de admin são criadas à mão, como as dos alunos, porque o cadastro público continua
   desligado.
2. **Autorização centralizada.** Um helper irmão de `serveEndpoint` em `_shared/http.ts` confere o
   papel e devolve `403` para quem não é admin. As edge functions conectam com a role `postgres`,
   que ignora o RLS, então essa conferência é a única barreira: ela fica num lugar só, nunca
   repetida em cada endpoint.
3. **Endpoints.** Uma edge function por endpoint, como as atuais (por exemplo `admin-create-question`,
   `admin-create-topic`, `admin-update-subject`), com o corpo validado por zod e a escrita em uma
   transação, no padrão de `submit-quiz-attempt`. Edição e remoção exigem que `serveEndpoint` aceite
   outros métodos além de `GET` e `POST`, ou que tudo use `POST`.
4. **Regras de validação.** Reaproveitar as do `import-quiz.sql`: validar o payload inteiro antes de
   gravar e não criar disciplina ou assunto implicitamente a partir de uma questão, para um erro de
   digitação não gerar duplicatas.
5. **Contrato** (aditivo, [`04-contratos-de-api.md`](04-contratos-de-api.md), seção 1.4): as rotas
   novas ficam sob um prefixo próprio (`/admin/...`) e não mudam nenhuma rota do aluno. O RLS e as
   grants continuam iguais ([`06-modelagem-de-dados.md`](06-modelagem-de-dados.md)): o cliente segue
   sem escrever direto em tabela nenhuma.
6. **UI (opcional).** Uma feature `src/features/admin/`, com rotas protegidas pelo papel no
   `router.tsx` (hoje `ProtectedRoute` só confere se há sessão) e o papel exposto no `useAuthStore`.
   Sem telas, os endpoints já podem ser usados por ferramentas como curl ou Postman.
7. **Documentação.** Ao implementar, atualizar [`03-arquitetura-tecnica.md`](03-arquitetura-tecnica.md),
   [`04-contratos-de-api.md`](04-contratos-de-api.md), [`06-modelagem-de-dados.md`](06-modelagem-de-dados.md)
   e [`99-criterios-de-aceite-mvp.md`](99-criterios-de-aceite-mvp.md), e remover este item daqui.

---

## 17. Resetar o preparo de um simulado

**Situação atual.** O preparo é calculado a partir de todas as respostas que o aluno já enviou
(`private.v_student_subject_performance` e `private.v_student_topic_performance`), sem distinguir de
qual tentativa vieram. Não há como descartar um simulado: as tentativas antigas continuam pesando no
preparo da disciplina, nos assuntos prioritários e no painel de Início para sempre.

**Objetivo.** Um botão "Resetar preparo" em cada simulado, para o aluno zerar completamente o preparo
que vem dele e recomeçar do zero, por exemplo depois de estudar de novo o conteúdo.

**Por que fica para depois do MVP.** O MVP ainda está fechando o ciclo de responder e ver o
resultado, e um reset só faz sentido quando o aluno tiver feito o mesmo simulado várias vezes.

**Proposta.**

1. **Modelo de dados.** Em vez de apagar as tentativas, marcá-las como descartadas (por exemplo
   `quiz_attempts.reset_at`, nulo nas válidas), em uma migration nova. As views de desempenho passam
   a ignorar as tentativas com `reset_at` preenchido, então o preparo volta a zero para aquele
   simulado sem perder o registro do que foi feito.
2. **Contrato** (aditivo, [`04-contratos-de-api.md`](04-contratos-de-api.md), seção 1.4):
   `POST /quizzes/:id/reset` marca todas as tentativas do aluno autenticado naquele simulado e
   devolve `204`. A edge function só altera tentativas do próprio aluno, nunca as de outro.
3. **Regras a decidir.**
   - Se o histórico de provas (item 15) mostra as tentativas resetadas, com a indicação de que não
     contam mais no preparo, ou as esconde.
   - Os indicadores de esforço do ranking (questões respondidas, simulados concluídos, dias
     estudados) **não** devem ser zerados: o reset apaga o desempenho, não o esforço já feito
     ([`02-regras-de-negocio.md`](02-regras-de-negocio.md), seção 11).
4. **UI.** O botão fica no card do simulado na lista, desabilitado quando não há tentativas, e pede
   confirmação explicando que o preparo daquele simulado será zerado e que a ação não pode ser
   desfeita. Depois do reset, as queries de simulados, disciplinas e painel são invalidadas no
   TanStack Query.
5. **Mock.** `handlers.ts` ganha a rota, descartando as tentativas guardadas no mock.
6. **Documentação.** Ao implementar, atualizar [`02-regras-de-negocio.md`](02-regras-de-negocio.md),
   [`04-contratos-de-api.md`](04-contratos-de-api.md) e
   [`06-modelagem-de-dados.md`](06-modelagem-de-dados.md), e remover este item daqui.
