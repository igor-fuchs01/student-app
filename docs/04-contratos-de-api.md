# Contratos de API

Este documento descreve os contratos de API **atualmente implementados** pelo frontend.
A fonte da verdade é o código; atualize este documento sempre que algo abaixo mudar:

| O quê | Onde |
|---|---|
| Caminhos dos endpoints | `src/services/api/endpoints.ts` |
| Formato de request/response (schemas zod) | `src/types/auth.ts`, `src/types/dashboard.ts`, `src/types/subjects.ts`, `src/types/quizzes.ts`, `src/types/ranking.ts` |
| Códigos de erro e corpo do erro | `src/services/api/errors.ts` |
| Transporte e tratamento de erro no modo mock | `src/services/api/httpClient.ts` |
| Transporte e tratamento de erro no Supabase | `src/services/api/supabase/` |
| Implementação do mock (MSW) | `src/services/api/mocks/handlers.ts` |
| Implementação no Supabase (funções do banco e login) | `supabase/migrations/` e o Supabase Auth |

Funcionalidades planejadas (desempenho, recomendações, sincronização de tentativas, etc.) ainda
não têm contrato; os materiais só aparecem como link dentro do detalhe da disciplina, sem tela
própria. As mudanças de contrato já previstas estão em
[`05-melhorias-futuras.md`](05-melhorias-futuras.md). Apenas os endpoints listados abaixo existem hoje.

---

## 1. Convenções gerais

### 1.1 Ambientes e URL base

| Comando | Arquivo de env | Para onde vão as requisições |
|---|---|---|
| `npm run mock` | `.env.mock` | Prefixo `/api` na própria origem, interceptado no navegador pelo MSW — nenhum backend |
| `npm run dev` | `.env.development` (copie de `.env.development.example`) | Supabase em `VITE_SUPABASE_URL` (local: `http://127.0.0.1:54321`) |

No modo mock, todo caminho descrito neste documento é relativo a `/api`. Exemplo:
`POST /auth/login` → `POST /api/auth/login`.

No Supabase, cada endpoint é uma edge function (ou, no login e no logout, uma chamada do Supabase
Auth) que recebe os mesmos dados e devolve o mesmo JSON (tabela abaixo). Os módulos `*Api`
escolhem o transporte, então as telas usam os mesmos métodos nos dois modos. O banco não tem
função nenhuma exposta: as edge functions leem as tabelas e views e montam o JSON em TypeScript.

| Endpoint | No Supabase (edge function) |
|---|---|
| `POST /auth/login` | `supabase.auth.signInWithPassword()` com o e-mail `<accessCode>@alunos.student-app.invalid`, depois `GET get-current-student` |
| `POST /auth/logout` | `supabase.auth.signOut()` |
| `GET /dashboard` | `GET get-dashboard?period=&subjectId=` |
| `GET /subjects` | `GET list-subjects` |
| `GET /subjects/:id` | `GET get-subject?id=:id` |
| `GET /quizzes` | `GET list-quizzes` |
| `GET /exercises` | `GET list-exercises?topicId=` |
| `GET /quizzes/:id` | `GET get-quiz?id=:id` |
| `POST /quizzes/:id/attempts` | `POST submit-quiz-attempt`, com o corpo `{ quizId, answers }` |
| `GET /ranking` | `GET get-ranking` |
| `GET /ranking/activity` | `GET get-activity-calendar?month=` |

Quando os mocks estão desativados, `VITE_SUPABASE_URL` (URL `http://` ou `https://`) e
`VITE_SUPABASE_PUBLISHABLE_KEY` são obrigatórias; sem elas a aplicação se recusa a iniciar. As
regras de acesso do banco estão em [`06-modelagem-de-dados.md`](06-modelagem-de-dados.md).

`VITE_TURNSTILE_SITE_KEY` é opcional: com ela, a tela de login mostra o CAPTCHA do Cloudflare
Turnstile (veja [`POST /auth/login`](#post-authlogin)). No modo mock ela é ignorada.

#### Edge functions e CORS

As edge functions ficam em `supabase/functions/` (Deno + TypeScript), uma pasta por endpoint.
O que elas compartilham está em `supabase/functions/_shared/`:

- `http.ts` — `serveEndpoint(method, handler)`: responde o preflight, recusa outro método, valida
  o JWT (`auth.getClaims`), acha o aluno em `students` e transforma um `ApiError` no corpo de erro
  do contrato; qualquer outra falha vira `500` com código `UNKNOWN_ERROR`;
- `db.ts` — conexão direta com o Postgres (`SUPABASE_DB_URL`, driver `npm:postgres`), que alcança
  as views do schema `private` e permite transação. Ela ignora o RLS, então toda consulta filtra
  pelo aluno do token;
- `subjects.ts` e `questions.ts` — consultas usadas por mais de um endpoint;
- `cors.ts` — o CORS de todas elas:

- só as origens listadas no secret `ALLOWED_ORIGINS` (separadas por vírgula) recebem
  `Access-Control-Allow-Origin`; qualquer outra origem fica sem o header e o navegador bloqueia a
  resposta;
- o preflight `OPTIONS` responde `204`; os headers aceitos são `authorization, x-client-info,
  apikey, content-type` e os métodos, `GET, POST, OPTIONS`; outro método responde `405` com código
  `METHOD_NOT_ALLOWED`;
- localmente o valor vem de `supabase/functions/.env` (copie de `.env.example`); no projeto
  hospedado, de `npx supabase secrets set ALLOWED_ORIGINS=...`. O gateway local (Kong) acrescenta
  `Access-Control-Allow-Origin: *` a toda resposta, então a restrição só aparece no projeto
  hospedado ou chamando o runtime direto.

`verify_jwt` fica desligado para essas funções no `config.toml`: o gateway recusaria o preflight,
que não leva token. Cada função valida o JWT do aluno por conta própria (`auth.getClaims`).

### 1.2 Formato

- Os corpos de request e response são JSON (UTF-8).
- Toda requisição envia `Accept: application/json`.
- Requisições com corpo também enviam `Content-Type: application/json`.
- Endpoints sem corpo de resposta retornam `204 No Content`.

### 1.3 Autenticação

- A autenticação usa um **token Bearer** obtido em `POST /auth/login`.
- Endpoints autenticados exigem o header:

  ```http
  Authorization: Bearer <token>
  ```

- O token é **opaco** para o cliente: é armazenado e reenviado como está, nunca é interpretado.
- Um token ausente, inválido ou expirado deve retornar `401` com código `UNAUTHORIZED`.
- No Supabase, o token é o JWT do Supabase Auth. Ele vale 1 hora e o SDK o renova sozinho; o SDK
  também envia o header em cada chamada, sem passar pelo `httpClient`. Um `401` ou `403` numa
  chamada autenticada desloga o aluno, como no modo mock.

### 1.4 Validação de resposta e compatibilidade

O cliente valida todo corpo de resposta contra um schema zod antes de utilizá-lo.

- Uma resposta `2xx` cujo corpo não corresponde ao schema é rejeitada no cliente com o
  código `INVALID_RESPONSE` (veja [Erros](#4-erros)).
- **Campos desconhecidos são descartados**, então o servidor pode adicionar novos campos
  sem quebrar o cliente.
- Remover um campo, renomeá-lo, mudar seu tipo, ou restringir seus valores permitidos
  **é uma mudança incompatível (breaking change)** e deve ser coordenada com um release
  do frontend.

### 1.5 Limites de tamanho

Não há limite de requisições por aluno: o único rate limit é o do Supabase Auth, que cobre o login.
O que existe são tetos de tamanho no envio de simulado. No modo mock não há limite nenhum.

- O schema zod da edge function `submit-quiz-attempt` recusa, com `400` e código
  `VALIDATION_ERROR`, uma lacuna (`blankAnswers`) acima de **2000 caracteres**, um `text` acima
  de **20000**, mais de **200** respostas ou mais de **50** `optionIds` numa resposta. É um teto
  de segurança, não uma regra de produto: uma resposta real fica três ordens de grandeza abaixo
  dele. O limite de uma questão `essay` continua sendo o
  `maxLength` da própria questão, conferido no banco.

---

## 2. Resumo dos endpoints

| Método | Caminho | Autenticação | Resposta de sucesso | Método no cliente |
|---|---|---|---|---|
| `POST` | `/auth/login` | Não | `200` [`AuthSession`](#32-authsession) | `authApi.login` |
| `POST` | `/auth/logout` | Sim | `204` (sem corpo) | `authApi.logout` |
| `GET` | `/dashboard` | Sim | `200` [`DashboardData`](#34-dashboarddata) | `dashboardApi.getDashboard` |
| `GET` | `/subjects` | Sim | `200` [`Subject`](#39-subject)`[]` | `subjectsApi.getSubjects` |
| `GET` | `/subjects/:id` | Sim | `200` [`SubjectDetail`](#316-subjectdetail) | `subjectsApi.getSubject` |
| `GET` | `/quizzes` | Sim | `200` [`QuizSummary`](#310-quizsummary)`[]` | `quizzesApi.getQuizzes` |
| `GET` | `/exercises` | Sim | `200` [`ExerciseSummary`](#320-exercisesummary)`[]` | `quizzesApi.getExercises` |
| `GET` | `/quizzes/:id` | Sim | `200` [`QuizDetail`](#311-quizdetail) | `quizzesApi.getQuiz` |
| `POST` | `/quizzes/:id/attempts` | Sim | `200` [`QuizResult`](#314-quizresult) | `quizzesApi.submitQuizAttempt` |
| `GET` | `/ranking` | Sim | `200` [`RankingData`](#315-rankingdata) | `rankingApi.getRanking` |
| `GET` | `/ranking/activity` | Sim | `200` [`ActivityCalendar`](#321-activitycalendar) | `rankingApi.getActivityCalendar` |

---

## 3. Endpoints e modelos

### `POST /auth/login`

Autentica uma conta de aluno pré-provisionada (não há cadastro público). Por causa da LGPD, o
login não usa nenhum dado pessoal: o aluno entra com um **código de acesso** gerado pela
instituição, e o nome que ele digita na tela de login fica só no navegador (veja
[`StudentUser`](#31-studentuser)).

**Autenticação:** não exigida. O cliente nunca envia um header `Authorization` aqui.

**Corpo da requisição** — `LoginCredentials`

| Campo | Tipo | Regras | Descrição |
|---|---|---|---|
| `accessCode` | string | Obrigatório. Sofre trim e vira minúsculas; 6 a 32 letras ou dígitos. | Código de acesso gerado pela instituição. |
| `password` | string | Obrigatório. Não pode ser vazio. | Senha da conta. |

```json
{
  "accessCode": "demo0001",
  "password": "123456"
}
```

**CAPTCHA (só no Supabase).** Com o CAPTCHA ativado no Supabase Auth (Authentication → Attack
Protection, provedor Turnstile), o login exige um token do widget do Cloudflare Turnstile, enviado
em `signInWithPassword({ ..., options: { captchaToken } })`. O token não faz parte de
`LoginCredentials`: a tela o obtém do widget e o passa à parte para `authApi.login`. Cada token vale
para uma única tentativa, então a tela reinicia o widget depois de qualquer falha. Quem confere o
token é o Supabase Auth, com a secret key que só ele conhece; o mock não exige token.

**Respostas**

| Status | Corpo | Quando |
|---|---|---|
| `200` | [`AuthSession`](#32-authsession) | As credenciais são válidas. |
| `400` | Erro, código `VALIDATION_ERROR` | Corpo ausente ou inválido, código em branco ou malformado, ou senha vazia. |
| `400` | Erro, código `CAPTCHA_FAILED` | Só no Supabase com CAPTCHA ativado: token ausente, expirado ou já usado. As credenciais nem chegam a ser conferidas. |
| `401` | Erro, código `INVALID_CREDENTIALS` | Nenhuma conta corresponde ao código, ou a senha está errada. |

```json
{
  "token": "eyJhbGciOi...",
  "user": {
    "id": "u_demo0001",
    "course": "Análise e Desenvolvimento de Sistemas"
  }
}
```

**Comportamento no cliente**

- Em caso de sucesso, o token e o usuário são salvos no `localStorage`, restaurando a
  sessão ao recarregar a página.
- O nome digitado no formulário não faz parte do corpo: é salvo só no `localStorage`
  (`displayNameStorage`) e apagado no logout.
- Um `401` aqui significa credenciais erradas, não uma sessão expirada, então **não**
  dispara o logout global descrito em [4.3](#43-tratamento-no-cliente).

---

### `POST /auth/logout`

Encerra a sessão atual no servidor.

**Autenticação:** exigida. **Corpo da requisição:** nenhum.

**Respostas**

| Status | Corpo | Quando |
|---|---|---|
| `204` | — | Sessão encerrada. |
| `401` | Erro, código `UNAUTHORIZED` | Token ausente, inválido, ou já expirado. |

**Comportamento no cliente:** a sessão local é limpa e o aluno é deslogado
independentemente de esta requisição ter sucesso ou falhar.

---

### `GET /dashboard`

Retorna o painel da tela de Início do aluno autenticado: o preparo e a evolução dele nos
últimos `period` dias, comparados com os `period` dias anteriores, e os assuntos que mais
precisam de atenção. Só traz dados numéricos; textos e formatação ficam na UI.

**Autenticação:** exigida. **Corpo da requisição:** nenhum.

**Query string**

| Parâmetro | Tipo | Regras |
|---|---|---|
| `period` | integer | Opcional. `30`, `90` ou `180` (dias, contando hoje). Padrão `90`. |
| `subjectId` | string | Opcional. Limita tudo, exceto `streakDays` e `weeklyGoal`, a uma disciplina. |

Um percentual é sempre acertos sobre questões corrigidas: respostas `pending_review` (dissertativas
ainda sem autocorreção) contam como respondidas, mas não entram no percentual.

**Respostas**

| Status | Corpo | Quando |
|---|---|---|
| `200` | [`DashboardData`](#34-dashboarddata) | Sempre, para um aluno autenticado. |
| `400` | Erro, código `VALIDATION_ERROR` | `period` diferente de `30`, `90` ou `180`. |
| `401` | Erro, código `UNAUTHORIZED` | Token ausente, inválido, ou expirado. |
| `404` | Erro, código `NOT_FOUND` | `subjectId` não numérico ou de disciplina inexistente. |

```json
{
  "streakDays": 9,
  "preparation": { "percent": 71.3, "previousPercent": 68.02 },
  "questionsAnswered": { "count": 600, "previousCount": 535 },
  "weeklyGoal": { "completed": 35, "target": 50 },
  "weeklyAccuracy": [
    {
      "weekStart": "2026-09-17",
      "weekEnd": "2026-09-23",
      "answeredCount": 40,
      "gradedCount": 38,
      "correctCount": 28,
      "percent": 73.68
    },
    {
      "weekStart": "2026-09-24",
      "weekEnd": "2026-09-30",
      "answeredCount": 75,
      "gradedCount": 74,
      "correctCount": 57,
      "percent": 77.03
    }
  ],
  "preparationBreakdown": {
    "scope": "subject",
    "items": [
      { "id": "2", "name": "Algoritmos", "gradedCount": 123, "correctCount": 97, "percent": 78.86 },
      { "id": "1", "name": "Banco de Dados", "gradedCount": 98, "correctCount": 63, "percent": 64.29 }
    ]
  },
  "studyFocus": {
    "items": [
      {
        "topicId": "7",
        "topicName": "Modelagem ER",
        "topicNumber": 1,
        "subjectId": "1",
        "subjectShortLabel": "BD",
        "percent": 42.11,
        "gradedCount": 38,
        "recentWrongCount": 4,
        "level": "high"
      }
    ],
    "totalCount": 6
  }
}
```

**Comportamento no cliente**

- A requisição é cancelada se a tela deixar de precisar dela; uma requisição cancelada
  não é tratada como erro.
- Os filtros ficam na URL da tela (`/?periodo=30&disciplina=1`); trocar um filtro refaz a
  requisição mantendo o painel anterior na tela, esmaecido, até a resposta chegar.
- O card "O que estudar agora" mostra só o primeiro item, em três partes:
  - **Assunto:** selo de prioridade vindo de `level` ("Prioridade alta", "Prioridade média" ou
    "Pouca prática"), nome do assunto e "{sigla} · Aula {topicNumber}".
  - **Por que agora:** barra de acerto com o marcador da meta de 80% e "Seu acerto: {percent}" /
    "Meta: 80%" (a barra some quando `percent` é `null`), mais uma frase de motivo: poucas
    questões corrigidas para `few_practice`; senão, os erros dos últimos 14 dias
    (`recentWrongCount`); senão, o acerto abaixo da meta.
  - **Próximo passo:** a ação sugerida (de `level` e `recentWrongCount`), com tempo estimado no
    cliente (2 min por questão, mais 10 min quando inclui revisar o material), e o botão
    "Estudar agora", que leva a `/disciplinas/:subjectId`.
- Se `totalCount` passar de 1, o rodapé do card tem "Ver os outros {totalCount - 1} assuntos",
  que abre um modal com os demais itens devolvidos (até 4), cada um com nome, selo, sigla, aula e
  a frase de motivo; clicar leva a `/disciplinas/:subjectId`. Quando `totalCount` é maior que os
  itens devolvidos, o modal avisa que mostra só os de maior prioridade.
- Sem nenhuma questão respondida no período, a tela convida a fazer um simulado em vez de
  mostrar gráficos vazios.

---

### `GET /subjects`

Retorna as disciplinas do curso do aluno autenticado.

**Autenticação:** exigida. **Corpo da requisição:** nenhum.

**Respostas**

| Status | Corpo | Quando |
|---|---|---|
| `200` | [`Subject`](#39-subject)`[]` | Sempre, para um aluno autenticado. Pode ser vazio. |
| `401` | Erro, código `UNAUTHORIZED` | Token ausente, inválido, ou expirado. |

```json
[
  {
    "id": "banco-de-dados",
    "name": "Banco de Dados",
    "shortLabel": "BD",
    "materialsCount": 12,
    "questionsCount": 84,
    "preparationPercent": 72
  }
]
```

**Comportamento no cliente:** as disciplinas são renderizadas na ordem do array. Cada card é um
link para `/disciplinas/:subjectId`. Não há card de simulado integrado: todo simulado é de uma
disciplina.

---

### `GET /subjects/:id`

Retorna uma disciplina com os assuntos cobrados nela, os subassuntos de cada assunto e os materiais
de cada subassunto. É o que a tela `/disciplinas/:subjectId` exibe.

**Autenticação:** exigida. **Corpo da requisição:** nenhum.

**Respostas**

| Status | Corpo | Quando |
|---|---|---|
| `200` | [`SubjectDetail`](#316-subjectdetail) | A disciplina existe. |
| `401` | Erro, código `UNAUTHORIZED` | Token ausente, inválido, ou expirado. |
| `404` | Erro, código `NOT_FOUND` | Nenhuma disciplina com esse `id`. |

```json
{
  "id": "banco-de-dados",
  "name": "Banco de Dados",
  "shortLabel": "BD",
  "materialsCount": 8,
  "questionsCount": 84,
  "preparationPercent": 72,
  "topics": [
    {
      "id": "modelagem-conceitual",
      "number": 1,
      "name": "Fundamentos e Modelagem Conceitual",
      "description": "Como transformar um problema do mundo real em um modelo entidade-relacionamento.",
      "subtopics": [
        {
          "id": "modelo-er",
          "name": "Modelo Entidade-Relacionamento",
          "summary": "O modelo ER descreve o domínio em entidades, atributos e relacionamentos, antes de qualquer decisão sobre tabelas.",
          "keyPoints": ["Entidade: objeto do mundo real com existência própria."],
          "materials": [
            {
              "id": "apostila-modelagem-er",
              "title": "Apostila — Modelagem ER",
              "fileUrl": "/materiais/banco-de-dados/apostila-modelagem-er.pdf"
            }
          ]
        }
      ]
    }
  ]
}
```

**Comportamento no cliente**

- Os assuntos já vêm ordenados por `number`, que é a ordem alfabética do rótulo lido pelo aluno
  ("Aula 1 - …", "Aula 2 - …") e continua correta a partir da décima aula. A posição no array nunca
  é usada para numerar.
- A lista lateral monta o rótulo do assunto como `Aula {number} - {name}`; o cabeçalho da direita
  mostra "Aula {number}" e o nome em linhas separadas.
- Os subassuntos, os pontos-chave e os materiais seguem a ordem do array, que é a ordem de estudo
  definida pela equipe — não é alfabética.
- A lista lateral agrupa os subassuntos por assunto. O primeiro subassunto do primeiro assunto já
  vem selecionado, e escolher outro troca as duas seções da direita sem nova requisição.
- Uma disciplina sem assuntos, ou cujos assuntos não têm subassuntos, exibe um aviso no lugar da
  lista.
- `summary`, `keyPoints` e `description` são texto simples, sem HTML ou Markdown, para não exigir um
  renderizador de conteúdo rico nesta etapa.
- Os materiais abrem `fileUrl` em outra aba; não existe tela de materiais.
- "Praticar questões" leva para `/exercicios?assunto={topic.id}`: as listas de exercícios do
  assunto do subassunto selecionado (ver [`GET /exercises`](#get-exercises)). As questões são
  classificadas por assunto, não por subassunto.

---

### `GET /quizzes`

Lista os simulados disponíveis para o aluno. As listas de exercícios não entram aqui (ver
[`GET /exercises`](#get-exercises)).

**Autenticação:** exigida. **Corpo da requisição:** nenhum.

**Respostas**

| Status | Corpo | Quando |
|---|---|---|
| `200` | [`QuizSummary`](#310-quizsummary)`[]` | Sempre, para um aluno autenticado. Pode ser vazio. |
| `401` | Erro, código `UNAUTHORIZED` | Token ausente, inválido, ou expirado. |

```json
[
  {
    "id": "bd-1",
    "title": "Banco de Dados — Simulado 1",
    "subjectName": "Banco de Dados",
    "questionCount": 4,
    "durationMinutes": 10,
    "attemptsCount": 2,
    "difficulty": "hard"
  }
]
```

**Comportamento no cliente:** acima da tabela há dois filtros, aplicados na própria tela sobre a
lista já carregada: disciplina (as `subjectName` presentes na resposta) e dificuldade (Fácil, Média
ou Difícil). Se nenhum simulado atende aos filtros, aparece um aviso no lugar da tabela. Não há
limite de tentativas. `attemptsCount` é exibido apenas como
informação; o botão "Iniciar" está sempre disponível.

---

### `GET /exercises`

Lista as listas de exercícios: cada uma reúne questões de um único assunto e não tem limite de
tempo. Uma lista de exercícios é um quiz, então a tentativa usa os mesmos
[`GET /quizzes/:id`](#get-quizzesid) e [`POST /quizzes/:id/attempts`](#post-quizzesidattempts).

**Autenticação:** exigida. **Corpo da requisição:** nenhum.

**Query string**

| Parâmetro | Tipo | Regras |
|---|---|---|
| `topicId` | string | Opcional. Devolve só as listas desse assunto (o `id` de [`SubjectTopic`](#317-subjecttopic)). O filtro é feito no banco, pelo índice de `quizzes.topic_id`. Sem ele, vêm todas as listas. |

**Respostas**

| Status | Corpo | Quando |
|---|---|---|
| `200` | [`ExerciseSummary`](#320-exercisesummary)`[]` | Sempre, para um aluno autenticado. Pode ser vazio, inclusive para um assunto que existe mas ainda não tem listas. |
| `401` | Erro, código `UNAUTHORIZED` | Token ausente, inválido, ou expirado. |
| `404` | Erro, código `NOT_FOUND` | `topicId` não numérico ou de assunto inexistente. |

```json
[
  {
    "id": "ex-sql-1",
    "title": "SQL — Exercícios 1",
    "subjectId": "banco-de-dados",
    "subjectName": "Banco de Dados",
    "topicId": "sql",
    "topicNumber": 3,
    "topicName": "SQL: Definição e Manipulação",
    "questionCount": 2,
    "attemptsCount": 0,
    "difficulty": "easy"
  }
]
```

A lista vem ordenada por disciplina, número da aula e título; listas sem questões ficam de fora.

**Comportamento no cliente**

- A aba "Exercícios" (`/exercicios`) pede `GET /exercises` sem filtro (cache
  `["exercises", "all"]`) e mostra uma disciplina por vez, em lista e detalhe, sem título visível:
  - **Lista de aulas** (à esquerda): a disciplina selecionada em destaque (seletor grande, com
    "{n} aulas · {feitas} de {total} listas feitas" logo abaixo; ao abrir, cada disciplina aparece
    com o nome inteiro, quebrando linha se preciso, e "{feitas}/{total}"; dá para navegar com as
    setas, Home/End, Enter e Esc), busca pelo nome ou número da aula
    (sem diferenciar maiúsculas nem acentos), filtro Todas / Pendentes / Feitas e uma linha por
    aula com "Aula {topicNumber} · {topicName}", a situação (✓ todas feitas, ◐ em andamento,
    ○ não iniciada) e "{feitas}/{total}". Uma lista conta como feita quando `attemptsCount > 0`.
  - **Aula escolhida** (à direita): "Aula {topicNumber} · {topicName}" com "{n} de {total} listas
    feitas" ao lado e duas abas. "Listas ({total})", aberta por padrão, mostra um cartão por lista
    com título, selo de situação ("✓ Feita {attemptsCount}×" ou "Não feita"), nº de questões e
    "Iniciar" ou "Refazer"; só a primeira lista não feita tem o botão em destaque. "Resumo da
    aula" mostra o resumo e os pontos-chave. As setas ← e → alternam entre as abas. A dificuldade
    não é exibida.
- O resumo é a `description` do [`SubjectTopic`](#317-subjecttopic) e os pontos-chave são os
  `keyPoints` dos seus subassuntos, vindos de [`GET /subjects/:id`](#get-subjectsid) da disciplina
  selecionada, com a mesma chave de cache do detalhe da disciplina (`["subject", subjectId]`). Se
  esse pedido falhar, a aula mostra um aviso no lugar do resumo e as listas continuam disponíveis.
- A disciplina e a aula ficam na URL (`?disciplina={subjectId}&aula={topicId}`), então voltar,
  recarregar e compartilhar o link mantêm a seleção. Sem aula na URL, a tela mostra a primeira
  aula com lista pendente da disciplina (ou a primeira aula). `?assunto={topicId}` (vindo do
  "Praticar questões" do detalhe da disciplina) é aceito como sinônimo de `aula`; um assunto sem
  listas mostra um aviso com o link para ver todos.
- No celular (até `md`), a tela mostra só a lista de aulas; tocar numa aula abre só a aula, com
  "← Aulas" para voltar.
- O filtro `topicId` do endpoint continua disponível, mas a tela não o usa mais.
- "Iniciar" e "Refazer" abrem um pop-up de confirmação, sem escolha de cronômetro. A
  tentativa roda em `/exercicios/:id`, sem limite de tempo, com a mesma navegação, revisão, envio e
  resultado do simulado.
- Não há limite de tentativas; `attemptsCount` é só informativo.

---

### `GET /quizzes/:id`

Retorna um simulado ou uma lista de exercícios com todas as suas questões, usado durante a
tentativa.

**Autenticação:** exigida. **Corpo da requisição:** nenhum.

**Respostas**

| Status | Corpo | Quando |
|---|---|---|
| `200` | [`QuizDetail`](#311-quizdetail) | O simulado existe. |
| `401` | Erro, código `UNAUTHORIZED` | Token ausente, inválido, ou expirado. |
| `404` | Erro, código `NOT_FOUND` | Nenhum simulado com esse `id`. |

> Hoje a resposta inclui gabarito e explicações de cada questão. A separação está prevista
> em [`05-melhorias-futuras.md`](05-melhorias-futuras.md), item 2.

**Comportamento no cliente**

- Antes de começar um simulado, o aluno escolhe entre **tempo limite** (`durationMinutes`) e
  **sem limite**. Uma lista de exercícios não tem `durationMinutes` e começa sempre sem limite.
- O cronômetro é calculado a partir do instante de início da tentativa, não de um contador,
  então não atrasa quando a aba fica em segundo plano.
- No modo com tempo limite, quando o tempo acaba as respostas são travadas e a tentativa é
  enviada automaticamente. Se o envio falhar, a tela de revisão mostra o erro e permite
  tentar enviar de novo, sem voltar a responder.
- Sair da tentativa (navegação, fechar a aba ou "Sair") pede confirmação.
- As respostas ficam só em memória até o envio (ver
  [`05-melhorias-futuras.md`](05-melhorias-futuras.md), item 1).

---

### `POST /quizzes/:id/attempts`

Envia as respostas de uma tentativa e retorna a correção.

**Autenticação:** exigida.

**Corpo da requisição** — `SubmitQuizAttempt`

| Campo | Tipo | Regras |
|---|---|---|
| `answers` | [`QuizAnswer`](#313-quizanswer)`[]` | Obrigatório. Pode ser vazio. No máximo uma resposta por questão. Só as questões respondidas são enviadas: questões deixadas em branco, ou com lacunas incompletas, ficam de fora e contam como não respondidas. |

```json
{
  "answers": [
    { "questionId": "q1", "optionId": "q1-o2" },
    { "questionId": "q3", "blankAnswers": { "cmd1": "q3-cmd1-insert", "cmd2": "q3-cmd2-update" } }
  ]
}
```

**Respostas**

| Status | Corpo | Quando |
|---|---|---|
| `200` | [`QuizResult`](#314-quizresult) | Respostas corrigidas. |
| `400` | Erro, código `VALIDATION_ERROR` | Corpo ausente ou inválido. |
| `401` | Erro, código `UNAUTHORIZED` | Token ausente, inválido, ou expirado. |
| `404` | Erro, código `NOT_FOUND` | Nenhum simulado com esse `id`. |

**No Supabase:** a edge function `submit-quiz-attempt` recebe `{ quizId, answers }`, confere o JWT
e valida o formato com zod (ids numéricos, tamanhos de [1.5](#15-limites-de-tamanho)). Depois
confere cada resposta contra o gabarito do simulado (questão do simulado e sem repetição, opção,
lacuna ou termo da própria questão, `maxLength` da dissertativa) e corrige em TypeScript
(`grade.ts`). A tentativa, as respostas e o dia de estudo são gravados numa única transação, e o
`QuizResult` é calculado a partir das respostas corrigidas.

**Comportamento no cliente:** em caso de sucesso, `{ quiz, answers, result }` é salvo no
`localStorage` na chave `student-app:quiz-attempt:<userId>:<quizId>` e o aluno é levado para
`/simulados/:quizId/resultado`, que lê essa chave. O resultado de um aluno nunca aparece para
outro aluno no mesmo navegador.

---

### `GET /ranking`

Retorna o perfil de consistência do aluno e o ranking de consistência da turma.

**Autenticação:** exigida. **Corpo da requisição:** nenhum.

**Respostas**

| Status | Corpo | Quando |
|---|---|---|
| `200` | [`RankingData`](#315-rankingdata) | Sempre, para um aluno autenticado. |
| `401` | Erro, código `UNAUTHORIZED` | Token ausente, inválido, ou expirado. |

**Comportamento no cliente:** as três primeiras posições recebem medalha e a linha com
`isCurrentUser: true` é destacada. O ranking nunca exibe nota ou desempenho acadêmico
(ver [`02-regras-de-negocio.md`](02-regras-de-negocio.md), seção 11).

---

### `GET /ranking/activity`

Retorna o calendário de estudos de um mês do próprio aluno: os dias em que esteve ativo e quantos
simulados e listas de exercícios enviou em cada um. Nunca traz dados de outros alunos.

**Autenticação:** exigida. **Corpo da requisição:** nenhum.

**Query string**

| Parâmetro | Tipo | Regras |
|---|---|---|
| `month` | string | Opcional. `YYYY-MM`. Padrão: o mês atual. |

**Respostas**

| Status | Corpo | Quando |
|---|---|---|
| `200` | [`ActivityCalendar`](#321-activitycalendar) | Sempre, para um aluno autenticado. `days` pode ser vazio. |
| `400` | Erro, código `VALIDATION_ERROR` | `month` fora do formato `YYYY-MM`. |
| `401` | Erro, código `UNAUTHORIZED` | Token ausente, inválido, ou expirado. |

```json
{
  "month": "2026-10",
  "days": [
    { "date": "2026-10-01", "examsCount": 1, "exercisesCount": 0 },
    { "date": "2026-10-03", "examsCount": 0, "exercisesCount": 2 }
  ]
}
```

Um dia entra em `days` quando é um dia de estudo (`student_activity_days`) ou tem uma tentativa
enviada. As datas seguem o relógio do banco, o mesmo usado para registrar o dia de estudo no envio.

**Comportamento no cliente:** o calendário fica abaixo do perfil, na tela de ranking. Mostra um mês
por vez (domingo a sábado), começando no atual; as setas trocam de mês e não avançam além do mês
atual. Dias ativos ficam destacados, com um marcador laranja quando houve simulado e um verde
quando houve lista de exercícios, e o dia de hoje tem contorno. Abaixo vêm o total de dias ativos,
simulados e listas do mês. Cada mês é uma entrada própria no cache, e o mês anterior continua na
tela enquanto o próximo carrega.

---

### 3.1 `StudentUser`

| Campo | Tipo | Regras |
|---|---|---|
| `id` | string | Não vazio. Identificador único e estável do aluno. |
| `course` | string | Nome do curso. Pode ser vazio. |

Não há nome nem e-mail (LGPD). O nome que a tela mostra ("Olá, …", perfil e linha "Você" do
ranking) é o que o aluno digitou no login, guardado só no `localStorage` pelo
`displayNameStorage`; ele nunca vai para a API nem para o banco.

### 3.2 `AuthSession`

| Campo | Tipo | Regras |
|---|---|---|
| `token` | string | Não vazio. Token Bearer opaco. |
| `user` | [`StudentUser`](#31-studentuser) | Obrigatório. |

### 3.3 Texto de exibição

Campos como `title`, `name` e `description` são **textos prontos para exibição, em
português (pt-BR)**. O cliente os renderiza como estão, sem interpretar ou reformatar.
Números, datas e percentuais vêm crus (ex.: `GET /dashboard`); a UI formata.

### 3.4 `DashboardData`

| Campo | Tipo | Regras |
|---|---|---|
| `streakDays` | integer | `>= 0`. Dias consecutivos com atividade de estudo (todas as disciplinas). |
| `preparation` | object | `{ percent, previousPercent }`: acerto no período e no período anterior; cada um entre `0` e `100`, ou `null` sem questões corrigidas. |
| `questionsAnswered` | object | `{ count, previousCount }`: questões respondidas no período e no anterior; inteiros `>= 0`. |
| `weeklyGoal` | object | `{ completed, target }`: questões respondidas desde segunda-feira (todas as disciplinas) e a meta semanal (`> 0`). |
| `weeklyAccuracy` | [`WeeklyAccuracy`](#35-weeklyaccuracy)`[]` | Uma por janela de 7 dias do período, da mais antiga para a mais recente. |
| `preparationBreakdown` | object | `{ scope, items }`: `scope` é `"subject"` (sem `subjectId`) ou `"topic"` (com `subjectId`); `items` é [`PreparationItem`](#36-preparationitem)`[]`, do maior para o menor `percent`. |
| `studyFocus` | object | `{ items, totalCount }`: até 5 [`StudyFocusTopic`](#37-studyfocustopic), na ordem de prioridade, e quantos assuntos precisam de atenção no total. |

### 3.5 `WeeklyAccuracy`

| Campo | Tipo | Regras |
|---|---|---|
| `weekStart` | string | Data `YYYY-MM-DD`. A primeira janela pode começar depois, no início do período. |
| `weekEnd` | string | Data `YYYY-MM-DD`. A última janela termina hoje. |
| `answeredCount` | integer | `>= 0`. Questões respondidas na janela. |
| `gradedCount` | integer | `>= 0`. Questões corrigidas na janela. |
| `correctCount` | integer | `>= 0`. Acertos na janela. |
| `percent` | number \| null | Entre `0` e `100`; `null` quando nada foi corrigido na janela. |

### 3.6 `PreparationItem`

| Campo | Tipo | Regras |
|---|---|---|
| `id` | string | Não vazio. Id da disciplina ou do assunto, conforme o `scope`. |
| `name` | string | Nome da disciplina ou do assunto. |
| `topicNumber` | integer | Só quando `scope` é `"topic"`: o número da aula do assunto. |
| `gradedCount` | integer | `> 0`. Itens sem questões corrigidas no período não vêm. |
| `correctCount` | integer | `>= 0`. |
| `percent` | number | Entre `0` e `100`. |

### 3.7 `StudyFocusTopic`

| Campo | Tipo | Regras |
|---|---|---|
| `topicId` | string | Não vazio. |
| `topicName` | string | Nome do assunto. |
| `topicNumber` | integer | Número da aula do assunto. |
| `subjectId` | string | Não vazio. A UI leva o aluno para `/disciplinas/:subjectId`. |
| `subjectShortLabel` | string | Sigla da disciplina. |
| `percent` | number \| null | Acerto no período; `null` sem questões corrigidas. |
| `gradedCount` | integer | `>= 0`. Questões corrigidas no período. |
| `recentWrongCount` | integer | `>= 0`. Erros nos últimos 14 dias. |
| `level` | enum | `"high"` (acerto abaixo de 50%), `"medium"` (abaixo de 80%) ou `"few_practice"` (menos de 10 questões corrigidas no período). Assuntos com 80% ou mais não vêm. |

A ordem segue [`02-regras-de-negocio.md`](02-regras-de-negocio.md), seção 9: `high`, depois
`medium`, depois `few_practice`; dentro de cada nível, mais erros recentes primeiro e depois o
menor acerto.

### 3.8 Filtros do dashboard

`DashboardFilters` (`src/types/dashboard.ts`) é o par `{ period, subjectId? }` que a tela passa
para `dashboardApi.getDashboard` e que vira a query string de `GET /dashboard`.

### 3.9 `Subject`

| Campo | Tipo | Regras |
|---|---|---|
| `id` | string | Não vazio. Único. |
| `name` | string | Não vazio. Nome da disciplina. |
| `shortLabel` | string | Não vazio. Sigla exibida no avatar do card, ex.: `"BD"`. |
| `materialsCount` | integer | `>= 0`. |
| `questionsCount` | integer | `>= 0`. |
| `preparationPercent` | number | Entre `0` e `100`, inclusive. |

### 3.10 `QuizSummary`

| Campo | Tipo | Regras |
|---|---|---|
| `id` | string | Não vazio. Usado em `/quizzes/:id`. |
| `title` | string | Não vazio. |
| `subjectName` | string | Não vazio. Disciplina do simulado; todo simulado é de uma disciplina. |
| `questionCount` | integer | `> 0`. |
| `durationMinutes` | integer | `> 0`. Duração do modo com tempo limite. |
| `attemptsCount` | integer | `>= 0`. Quantas tentativas deste simulado o aluno já enviou. |
| `difficulty` | enum | `"easy"`, `"medium"`, ou `"hard"`. A UI exibe "Fácil", "Média" e "Difícil". |

### 3.11 `QuizDetail`

| Campo | Tipo | Regras |
|---|---|---|
| `id` | string | Não vazio. |
| `title` | string | Não vazio. |
| `durationMinutes` | integer | Opcional, `> 0`. Presente num simulado; ausente numa lista de exercícios, que não tem limite de tempo. |
| `questions` | [`Question`](#312-question)`[]` | Pelo menos uma questão. Exibidas na ordem do array. |

### 3.12 `Question`

União discriminada pelo campo `type`. Todos os tipos têm `id` (não vazio, único no simulado) e
`subjectName` (não vazio). `QuestionOption` é `{ "id": string, "text": string }`.

| `type` | Campos específicos |
|---|---|
| `multiple_choice` | `prompt`, `options` (`QuestionOption[]`, mín. 2), `correctOptionId`, `explanation` |
| `multiple_answer` | `prompt`, `options` (mín. 2), `correctOptionIds` (mín. 1), `explanation` |
| `single_choice` | `template`, `blanks` (`{ id, options, correctOptionId }[]`, mín. 1), `explanation` |
| `drag_and_drop` | `template`, `terms` (`{ id, text }[]`, mín. 2), `slots` (`{ id, correctTermId }[]`, mín. 1), `explanation` |
| `essay` | `prompt`, `maxLength` (integer `> 0`), `referenceAnswer` |
| `essay_blanks` | `prompt`, `template`, `blanks` (`{ id, referenceAnswer }[]`, mín. 1) |

Em `template`, cada lacuna é escrita como `{{id}}`, onde `id` é o `id` de um item de `blanks`
ou `slots`. O texto fora das lacunas é exibido como está.

### 3.13 `QuizAnswer`

| Campo | Tipo | Usado por |
|---|---|---|
| `questionId` | string | Todos. Não vazio. |
| `optionId` | string | `multiple_choice`. |
| `optionIds` | string[] | `multiple_answer`. |
| `text` | string | `essay`. |
| `blankAnswers` | objeto `{ [blankId]: string }` | `single_choice` (valor é o `id` da opção) e `essay_blanks` (valor é o texto digitado). |
| `slotAnswers` | objeto `{ [slotId]: termId }` | `drag_and_drop`. Um termo ocupa no máximo uma lacuna. |

Uma questão conta como respondida quando todas as suas lacunas estão preenchidas (ou, nos
demais tipos, quando há ao menos uma alternativa ou texto não vazio).

### 3.14 `QuizResult`

| Campo | Tipo | Regras |
|---|---|---|
| `quizId` | string | Não vazio. |
| `submittedAt` | string | Data/hora ISO 8601 do envio. |
| `correctCount` | integer | `>= 0`. |
| `incorrectCount` | integer | `>= 0`. |
| `unansweredCount` | integer | `>= 0`. |
| `selfReviewCount` | integer | `>= 0`. Dissertativas que o aluno deve autoavaliar. |
| `scorePercent` | number | Entre `0` e `100`. Acertos sobre `correctCount + incorrectCount + unansweredCount`. |
| `subjectPerformance` | `{ subjectName: string, percent: number }[]` | `percent` entre `0` e `100`. |
| `reviewItems` | `QuizReviewItem[]` | Questões erradas ou para autoavaliação. |

`QuizReviewItem`:

| Campo | Tipo | Regras |
|---|---|---|
| `questionId` | string | Não vazio. |
| `subjectName` | string | Não vazio. |
| `promptExcerpt` | string | Não vazio. Trecho do enunciado. |
| `status` | enum | `"incorrect"` ou `"self_review"`. |
| `explanation` | string | Opcional. Enviado para `incorrect`. |
| `studentAnswer` | string | Opcional. Enviado para `self_review`. |
| `referenceAnswer` | string | Opcional. Enviado para `self_review`. |

Na revisão da prova, uma questão sem `QuizReviewItem` aparece como "Correta" se foi respondida e
como "Não respondida" caso contrário.

### 3.15 `RankingData`

| Campo | Tipo | Regras |
|---|---|---|
| `profile.streakDays` | integer | `>= 0`. |
| `profile.weeklyGoalCompleted` | integer | `>= 0`. |
| `profile.weeklyGoalTarget` | integer | `> 0`. |
| `profile.questionsAnswered` | integer | `>= 0`. |
| `profile.quizzesCompleted` | integer | `>= 0`. Só simulados; listas de exercícios enviadas não contam. |
| `entries` | `RankingEntry[]` | Ordenado por posição. |

`RankingEntry`:

| Campo | Tipo | Regras |
|---|---|---|
| `position` | integer | `> 0`. |
| `studentId` | string | Não vazio. Único na lista. |
| `streakDays` | integer | `>= 0`. |
| `isCurrentUser` | boolean | `true` apenas na linha do aluno autenticado. |

Não há nome de aluno na lista. A tela mostra o nome local na linha do aluno autenticado e
"Estudante {position}" nas demais; empatados em sequência dividem a mesma posição.

### 3.16 `SubjectDetail`

Todos os campos de [`Subject`](#39-subject), mais:

| Campo | Tipo | Regras |
|---|---|---|
| `topics` | [`SubjectTopic`](#317-subjecttopic)`[]` | Assuntos da disciplina, na ordem de exibição. Pode ser vazio. |

### 3.17 `SubjectTopic`

Um assunto (aula) da disciplina, como em [`02-regras-de-negocio.md`](02-regras-de-negocio.md) §1.

| Campo | Tipo | Regras |
|---|---|---|
| `id` | string | Não vazio. Único na disciplina. |
| `number` | integer | `>= 1`. Único na disciplina. Número da aula na ementa; é ele que a tela exibe, não a posição no array. |
| `name` | string | Não vazio. Nome do assunto, sem o prefixo "Aula N" — a tela o compõe. |
| `description` | string | Não vazio. Uma frase sobre o que o assunto cobre. Texto simples. |
| `subtopics` | [`Subtopic`](#318-subtopic)`[]` | Subassuntos, na ordem de exibição. Pode ser vazio. |

### 3.18 `Subtopic`

| Campo | Tipo | Regras |
|---|---|---|
| `id` | string | Não vazio. Único na disciplina. |
| `name` | string | Não vazio. Nome do subassunto. |
| `summary` | string | Não vazio. Resumo curto, para revisar antes de estudar ou fazer um simulado. Texto simples. |
| `keyPoints` | string[] | Cada item não vazio. Pode ser vazio. Texto simples. |
| `materials` | [`Material`](#319-material)`[]` | Materiais do subassunto. Pode ser vazio. |

### 3.19 `Material`

| Campo | Tipo | Regras |
|---|---|---|
| `id` | string | Não vazio. Único na disciplina. |
| `title` | string | Não vazio. Título exibido na lista. |
| `fileUrl` | string | Não vazio. Endereço do arquivo, aberto em outra aba. |

### 3.20 `ExerciseSummary`

| Campo | Tipo | Regras |
|---|---|---|
| `id` | string | Não vazio. Usado em `/quizzes/:id`, como o de um simulado. |
| `title` | string | Não vazio. |
| `subjectId` | string | Não vazio. Disciplina do assunto. |
| `subjectName` | string | Não vazio. |
| `topicId` | string | Não vazio. Mesmo `id` de [`SubjectTopic`](#317-subjecttopic); escolhe a aula na tela por `?aula=` (ou `?assunto=`). |
| `topicNumber` | integer | `> 0`. Exibido como "Aula {topicNumber}". |
| `topicName` | string | Não vazio. |
| `questionCount` | integer | `> 0`. |
| `attemptsCount` | integer | `>= 0`. Quantas tentativas desta lista o aluno já enviou. |
| `difficulty` | enum | `"easy"`, `"medium"`, ou `"hard"`, como em [`QuizSummary`](#310-quizsummary). Não é exibido na tela de exercícios. |

### 3.21 `ActivityCalendar`

| Campo | Tipo | Regras |
|---|---|---|
| `month` | string | `YYYY-MM`. O mês pedido. |
| `days` | `ActivityDay[]` | Só os dias com atividade no mês, em ordem crescente de data. Pode ser vazio. |
| `days[].date` | string | Data ISO `YYYY-MM-DD`, dentro de `month`. |
| `days[].examsCount` | integer | `>= 0`. Simulados enviados no dia. |
| `days[].exercisesCount` | integer | `>= 0`. Listas de exercícios enviadas no dia. |

Um dia com os dois contadores em `0` foi um dia de estudo sem envio registrado; a tela o mostra só
como dia ativo.

---

## 4. Erros

### 4.1 Corpo do erro

Toda resposta não-`2xx` do servidor deve usar este corpo:

```json
{
  "code": "INVALID_CREDENTIALS",
  "message": "Código de acesso ou senha inválidos."
}
```

| Campo | Tipo | Regras |
|---|---|---|
| `code` | string | Um dos códigos em [4.2](#42-códigos-de-erro). |
| `message` | string | Não vazio. **Exibido diretamente ao aluno**, então deve ser um texto em português (pt-BR) amigável, sem detalhes técnicos. |

### 4.2 Códigos de erro

O cliente expõe toda falha como um `ApiError` com `status`, `code` e `message`.

| Código | Status HTTP | Produzido por | Significado |
|---|---|---|---|
| `VALIDATION_ERROR` | `400` | Servidor | O corpo da requisição está ausente ou inválido. |
| `INVALID_CREDENTIALS` | `401` | Servidor | Falha no login: código de acesso desconhecido ou senha errada. |
| `CAPTCHA_FAILED` | `400` | Servidor | Falha no login: o Supabase Auth recusou o token do CAPTCHA (ausente, expirado ou já usado). |
| `UNAUTHORIZED` | `401` | Servidor | Endpoint autenticado chamado sem um token válido. |
| `NOT_FOUND` | `404` | Servidor | A rota ou o recurso não existe. |
| `NETWORK_ERROR` | `0` | Cliente | Nenhuma resposta foi recebida (offline, falha de DNS, CORS, servidor fora do ar). |
| `INVALID_RESPONSE` | Status da resposta | Cliente | Um corpo `2xx` não correspondeu ao schema esperado. |
| `UNKNOWN_ERROR` | Status da resposta | Cliente | Uma resposta não-`2xx` cujo corpo não é um corpo de erro válido, ou cujo `code` não está nesta tabela. |

Se o servidor enviar um `code` não reconhecido com uma `message` válida, o cliente usa
`UNKNOWN_ERROR` mas ainda assim exibe a `message` do servidor. Caso contrário, exibe uma
mensagem genérica. Novos códigos precisam ser adicionados em `src/services/api/errors.ts`
para serem tratados de forma distinta.

### 4.3 Tratamento no cliente

- **`401` em uma requisição autenticada:** o cliente limpa a sessão armazenada, desloga
  o aluno, e redireciona para `/login`.
- **Fim de sessão (logout ou `401`):** o cache de dados do servidor (TanStack Query) é
  descartado, para que dados de um aluno não apareçam para o próximo.
- **Requisições canceladas** rejeitam com um `AbortError` padrão, não um `ApiError`, e
  não são exibidas como erro.
- **Corpos vazios** só são válidos para endpoints documentados como sem corpo de resposta (`204`).

---

## 5. Comportamento do servidor mock

Com `npm run mock`, o [MSW](https://mswjs.io/) (Mock Service Worker) implementa todos os
endpoints acima no navegador, com os mesmos status e corpos de erro. `mockServer.ts` registra o
Service Worker (`public/mockServiceWorker.js`) antes de o app renderizar, e as rotas ficam em
`src/services/api/mocks/handlers.ts`. O `httpClient` faz `fetch` normalmente para `/api/...`; o
worker intercepta essas chamadas, que aparecem na aba Rede do navegador como requisições reais.
Particularidades do mock:

- **URL base:** `/api`, na mesma origem do app — por exemplo, `POST /auth/login` vira
  `POST /api/auth/login`. O prefixo evita confusão com rotas de tela de mesmo nome, como
  `/ranking`.
- **Latência:** toda resposta é atrasada por `VITE_MOCK_DELAY_MS` (padrão `500` ms).
- **Conta de demonstração:** código de acesso `demo0001` (sem diferenciar maiúsculas/minúsculas),
  senha `123456`.
- **Formato do token:** um JWT (`header.payload.signature`, assinado com HMAC-SHA256), com o
  `id` do aluno no claim `sub` e expiração (`exp`) 3 dias após o login. Um token expirado, ou com
  assinatura inválida, é tratado como ausente e recebe `401 UNAUTHORIZED`. A assinatura usa um
  segredo fixo só do mock, sem nenhum valor de segurança real — o cliente continua tratando o
  token como opaco, sem decodificá-lo.
- **Rotas desconhecidas** sob `/api` retornam `404` com código `NOT_FOUND`. Pedidos fora de `/api`
  (arquivos da página, Vite) não são interceptados.
- **Disciplinas:** todas as disciplinas da lista têm detalhe, os assuntos saem ordenados por
  `number`, `materialsCount` é a soma dos materiais dos subassuntos, e os `fileUrl` apontam para
  arquivos que não existem no projeto. Além dos assuntos curados, cada disciplina ganha aulas extras
  (`EXTRA_LESSONS`), cada uma com um subassunto "Visão geral", pontos-chave e nenhum material, para
  as telas mostrarem um semestre cheio.
- **Simulados:** todos os simulados da lista têm detalhe. Cada um usa as questões da sua
  disciplina no banco do mock, e `questionCount` é calculado a partir delas. `attemptsCount` é
  contado em memória e volta a zero quando a página é recarregada.
- **Exercícios:** as listas ficam em `mocks/quizzes.ts`, cada uma com o assunto (ids de
  `mocks/subjects.ts`) e as questões do banco do mock escolhidas para ele. Alguns assuntos ficam
  sem lista de propósito, para a tela mostrar o aviso de assunto vazio. `topicId` usa os ids de
  texto do mock (ex.: `sql`) e um assunto que não existe responde `404`. O detalhe, o envio e o
  `attemptsCount` funcionam como os de um simulado. As aulas extras (e Lógica de Programação) têm
  de 1 a 4 listas
  (`EXTRA_LIST_COUNTS`) com as questões da disciplina, a lista sai na mesma ordem da edge function
  (disciplina, aula, título), e a conta `demo0001` começa com algumas listas já feitas, para a tela
  mostrar aulas feitas, em andamento e não iniciadas.
- **Correção:** `multiple_answer` só é correta com exatamente as alternativas corretas;
  `single_choice` e `drag_and_drop` exigem todas as lacunas corretas. Uma dissertativa (ou
  lacuna dissertativa) idêntica à referência, ignorando maiúsculas e espaços extras, é
  correta; caso contrário vira `self_review` (ver
  [`05-melhorias-futuras.md`](05-melhorias-futuras.md), item 5).
- **Dashboard:** o histórico vem de um gerador com semente fixa (`mocks/dashboard.ts`), com
  um ano de respostas sobre as disciplinas e assuntos do mock, e é agregado com as mesmas
  regras da edge function. Ele não muda quando o aluno envia um simulado no mock.
- **Calendário de estudos:** usa os dias de estudo desse mesmo histórico, então concorda com o
  dashboard. Cada dia ativo recebe uma mistura fixa de simulados e listas de exercícios, derivada
  do próprio dia; envios feitos no mock não aparecem nele.
- **Nota e desempenho por assunto:** questões `self_review` ficam fora de `scorePercent` e de
  `subjectPerformance`; questões não respondidas entram no denominador dos dois.
- **Bundle:** o MSW e os dados do mock são carregados por import dinâmico somente quando
  `VITE_USE_MOCKS=true`; builds de produção não incluem esse código. O arquivo estático
  `public/mockServiceWorker.js` vai em todo build, mas só é registrado em modo mock.

---

## 6. Alterando ou adicionando um contrato

1. Adicione ou altere o caminho em `src/services/api/endpoints.ts`.
2. Defina o formato de request/response como um schema zod em `src/types/` e exporte
   seu tipo `z.infer`.
3. Adicione ou atualize o método no módulo `*Api` da feature, passando o schema.
4. Implemente a rota em `src/services/api/mocks/handlers.ts`.
5. No Supabase, crie a edge function em `supabase/functions/<nome>/index.ts` com
   `serveEndpoint` (de `_shared/http.ts`), consultando o banco por `sql` (de `_shared/db.ts`) e
   montando o JSON em TypeScript; registre-a em `supabase/config.toml` com `verify_jwt = false` e
   chame-a no adaptador em `src/services/api/supabase/` com `callFunction`. Se precisar de tabela
   ou view nova, crie uma migration (`npx supabase migration new <nome>`), sem JSON no SQL. Siga as
   regras de acesso de [`06-modelagem-de-dados.md`](06-modelagem-de-dados.md).
6. Atualize este documento.

Prefira mudanças aditivas (novos campos opcionais, novos endpoints). Trate qualquer coisa
listada como incompatível em [1.4](#14-validação-de-resposta-e-compatibilidade) como algo
que exige coordenação.
