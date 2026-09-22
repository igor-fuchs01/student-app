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

No Supabase, cada endpoint é uma função no banco ou uma chamada do Supabase Auth que recebe os
mesmos dados e devolve o mesmo JSON (tabela abaixo). Os módulos `*Api` escolhem o transporte, então
as telas usam os mesmos métodos nos dois modos.

| Endpoint | No Supabase |
|---|---|
| `POST /auth/login` | `supabase.auth.signInWithPassword()`, depois `get_current_student()` |
| `POST /auth/logout` | `supabase.auth.signOut()` |
| `GET /dashboard` | `get_dashboard()` |
| `GET /subjects` | `list_subjects()` |
| `GET /subjects/:id` | `get_subject(p_subject_id)` — ainda não implementada (ver [`05-melhorias-futuras.md`](05-melhorias-futuras.md), item 7) |
| `GET /quizzes` | `list_quizzes()` |
| `GET /quizzes/:id` | `get_quiz(p_quiz_id)` |
| `POST /quizzes/:id/attempts` | `submit_quiz_attempt(p_quiz_id, p_answers)` |
| `GET /ranking` | `get_ranking()` |

Quando os mocks estão desativados, `VITE_SUPABASE_URL` (URL `http://` ou `https://`) e
`VITE_SUPABASE_PUBLISHABLE_KEY` são obrigatórias; sem elas a aplicação se recusa a iniciar. As
regras de acesso do banco estão em [`06-modelagem-de-dados.md`](06-modelagem-de-dados.md).

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
| `GET` | `/quizzes/:id` | Sim | `200` [`QuizDetail`](#311-quizdetail) | `quizzesApi.getQuiz` |
| `POST` | `/quizzes/:id/attempts` | Sim | `200` [`QuizResult`](#314-quizresult) | `quizzesApi.submitQuizAttempt` |
| `GET` | `/ranking` | Sim | `200` [`RankingData`](#315-rankingdata) | `rankingApi.getRanking` |

---

## 3. Endpoints e modelos

### `POST /auth/login`

Autentica uma conta de aluno pré-provisionada (não há cadastro público).

**Autenticação:** não exigida. O cliente nunca envia um header `Authorization` aqui.

**Corpo da requisição** — `LoginCredentials`

| Campo | Tipo | Regras | Descrição |
|---|---|---|---|
| `email` | string | Obrigatório. Sofre trim; precisa ser um e-mail válido. | E-mail institucional do aluno. A comparação não diferencia maiúsculas/minúsculas. |
| `password` | string | Obrigatório. Não pode ser vazio. | Senha da conta. |

```json
{
  "email": "igor@email.com",
  "password": "123456"
}
```

**Respostas**

| Status | Corpo | Quando |
|---|---|---|
| `200` | [`AuthSession`](#32-authsession) | As credenciais são válidas. |
| `400` | Erro, código `VALIDATION_ERROR` | Corpo ausente ou inválido, e-mail em branco ou malformado, ou senha vazia. |
| `401` | Erro, código `INVALID_CREDENTIALS` | Nenhuma conta corresponde ao e-mail, ou a senha está errada. |

```json
{
  "token": "eyJhbGciOi...",
  "user": {
    "id": "u_marina",
    "name": "Marina Alves",
    "email": "marina@aluno.ifpr.edu.br",
    "course": "Análise e Desenvolvimento de Sistemas"
  }
}
```

**Comportamento no cliente**

- Em caso de sucesso, o token e o usuário são salvos no `localStorage`, restaurando a
  sessão ao recarregar a página.
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

Retorna os dados agregados da tela de Início do aluno autenticado. É um endpoint
orientado à tela, que combina dados que, na API planejada, viriam de endpoints
separados de desempenho, recomendações e streak.

**Autenticação:** exigida. **Corpo da requisição:** nenhum.

**Respostas**

| Status | Corpo | Quando |
|---|---|---|
| `200` | [`DashboardData`](#34-dashboarddata) | Sempre, para um aluno autenticado. |
| `401` | Erro, código `UNAUTHORIZED` | Token ausente, inválido, ou expirado. |

```json
{
  "streakDays": 7,
  "nextExam": {
    "subjectName": "Banco de Dados",
    "dateLabel": "Sexta-feira, 18/09",
    "note": "Simulado integrado disponível",
    "overallPreparation": 72,
    "priorities": [
      { "id": "er-modeling", "topicName": "Modelagem ER", "level": "high" },
      { "id": "normalization", "topicName": "Normalização", "level": "medium" },
      { "id": "basic-sql", "topicName": "SQL básico", "level": "low" }
    ]
  },
  "todayPlan": [
    { "id": "review-er-modeling", "label": "Revisar Modelagem ER — 20 min", "done": false },
    { "id": "mini-quiz", "label": "Fazer mini-simulado do assunto", "done": true }
  ],
  "summaryCards": [
    {
      "id": "subjects",
      "title": "Disciplinas",
      "value": "5 matérias",
      "description": "Algoritmos, Arquitetura, SO, TI e Banco de Dados."
    }
  ]
}
```

**Comportamento no cliente**

- A requisição é cancelada se a tela deixar de precisar dela; uma requisição cancelada
  não é tratada como erro.
- Marcar ou desmarcar um item do `todayPlan` altera apenas o estado local da UI. Nenhum
  endpoint ainda persiste isso.

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
link para `/disciplinas/:subjectId`. O card do simulado integrado é fixo na UI, informa quantas
disciplinas foram retornadas e não é clicável.

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
- "Praticar questões" leva para `/simulados`, porque ainda não há como praticar um subassunto
  específico (ver [`05-melhorias-futuras.md`](05-melhorias-futuras.md), item 6).

---

### `GET /quizzes`

Lista os simulados disponíveis para o aluno.

**Autenticação:** exigida. **Corpo da requisição:** nenhum.

**Respostas**

| Status | Corpo | Quando |
|---|---|---|
| `200` | [`QuizSummary`](#310-quizsummary)`[]` | Sempre, para um aluno autenticado. Pode ser vazio. |
| `401` | Erro, código `UNAUTHORIZED` | Token ausente, inválido, ou expirado. |

```json
[
  {
    "id": "integrado",
    "title": "Simulado integrado",
    "subjectScope": "all",
    "questionCount": 13,
    "durationMinutes": 15,
    "attemptsCount": 2,
    "difficulty": "medium"
  }
]
```

**Comportamento no cliente:** não há limite de tentativas. `attemptsCount` é exibido apenas como
informação; o botão "Iniciar" está sempre disponível.

---

### `GET /quizzes/:id`

Retorna um simulado com todas as suas questões, usado durante a tentativa.

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

- Antes de começar, o aluno escolhe entre **tempo limite** (`durationMinutes`) e **sem limite**.
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

### 3.1 `StudentUser`

| Campo | Tipo | Regras |
|---|---|---|
| `id` | string | Não vazio. Identificador único e estável do aluno. |
| `name` | string | Não vazio. Nome completo; a UI cumprimenta o aluno pela primeira palavra. |
| `email` | string | Não vazio. E-mail institucional. |
| `course` | string | Nome do curso. Pode ser vazio. |

### 3.2 `AuthSession`

| Campo | Tipo | Regras |
|---|---|---|
| `token` | string | Não vazio. Token Bearer opaco. |
| `user` | [`StudentUser`](#31-studentuser) | Obrigatório. |

### 3.3 Texto de exibição

Campos como `dateLabel`, `note`, `label`, `title`, `value` e `description` são
**textos prontos para exibição, em português (pt-BR)**, já formatados pelo servidor.
O cliente os renderiza como estão, sem interpretar ou reformatar.

### 3.4 `DashboardData`

| Campo | Tipo | Regras |
|---|---|---|
| `streakDays` | integer | `>= 0`. Dias consecutivos com atividade de estudo. |
| `nextExam` | [`NextExam`](#35-nextexam) | Obrigatório. |
| `todayPlan` | [`StudyPlanItem`](#37-studyplanitem)`[]` | Obrigatório. Pode ser vazio. |
| `summaryCards` | [`DashboardSummaryCard`](#38-dashboardsummarycard)`[]` | Obrigatório. Pode ser vazio. |

### 3.5 `NextExam`

| Campo | Tipo | Regras |
|---|---|---|
| `subjectName` | string | Disciplina da próxima prova. |
| `dateLabel` | string | Texto de exibição, ex.: `"Sexta-feira, 18/09"`. |
| `note` | string | Texto de exibição. Pode ser vazio. |
| `overallPreparation` | number | Entre `0` e `100`, inclusive. Percentual de preparação. |
| `priorities` | [`TopicPriority`](#36-topicpriority)`[]` | Obrigatório. Pode ser vazio. Renderizado na ordem do array. |

### 3.6 `TopicPriority`

| Campo | Tipo | Regras |
|---|---|---|
| `id` | string | Não vazio. Único dentro da lista. |
| `topicName` | string | Nome de exibição do assunto. |
| `level` | enum | `"high"`, `"medium"`, ou `"low"`. |

A UI mapeia `level` para um badge: `high` → "Prioridade alta", `medium` → "Prioridade média",
`low` → "Em dia".

### 3.7 `StudyPlanItem`

| Campo | Tipo | Regras |
|---|---|---|
| `id` | string | Não vazio. Único dentro da lista. |
| `label` | string | Texto de exibição da tarefa. |
| `done` | boolean | Se a tarefa já foi concluída. |

### 3.8 `DashboardSummaryCard`

| Campo | Tipo | Regras |
|---|---|---|
| `id` | enum | `"subjects"`, `"quizzes"`, ou `"ranking"`. |
| `title` | string | Texto de exibição. |
| `value` | string | Texto de exibição, ex.: `"6 disponíveis"`. |
| `description` | string | Texto de exibição. |

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
| `subjectScope` | enum | `"single"` (uma disciplina) ou `"all"` (simulado integrado). |
| `subjectName` | string | Opcional. Presente quando `subjectScope` é `"single"`. |
| `questionCount` | integer | `> 0`. |
| `durationMinutes` | integer | `> 0`. Duração do modo com tempo limite. |
| `attemptsCount` | integer | `>= 0`. Quantas tentativas deste simulado o aluno já enviou. |
| `difficulty` | enum | `"easy"`, `"medium"`, ou `"hard"`. A UI exibe "Fácil", "Média" e "Difícil". |

### 3.11 `QuizDetail`

| Campo | Tipo | Regras |
|---|---|---|
| `id` | string | Não vazio. |
| `title` | string | Não vazio. |
| `durationMinutes` | integer | `> 0`. |
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
| `profile.quizzesCompleted` | integer | `>= 0`. |
| `entries` | `RankingEntry[]` | Ordenado por posição. |

`RankingEntry`:

| Campo | Tipo | Regras |
|---|---|---|
| `position` | integer | `> 0`. |
| `studentId` | string | Não vazio. Único na lista. |
| `studentName` | string | Não vazio. |
| `streakDays` | integer | `>= 0`. |
| `isCurrentUser` | boolean | `true` apenas na linha do aluno autenticado. |

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

---

## 4. Erros

### 4.1 Corpo do erro

Toda resposta não-`2xx` do servidor deve usar este corpo:

```json
{
  "code": "INVALID_CREDENTIALS",
  "message": "E-mail ou senha inválidos."
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
| `INVALID_CREDENTIALS` | `401` | Servidor | Falha no login: e-mail desconhecido ou senha errada. |
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
- **Conta de demonstração:** e-mail `igor@email.com` (sem diferenciar maiúsculas/minúsculas),
  senha `123456`.
- **Formato do token:** um JWT (`header.payload.signature`, assinado com HMAC-SHA256), com o
  `id` do aluno no claim `sub` e expiração (`exp`) 3 dias após o login. Um token expirado, ou com
  assinatura inválida, é tratado como ausente e recebe `401 UNAUTHORIZED`. A assinatura usa um
  segredo fixo só do mock, sem nenhum valor de segurança real — o cliente continua tratando o
  token como opaco, sem decodificá-lo.
- **Rotas desconhecidas** sob `/api` retornam `404` com código `NOT_FOUND`. Pedidos fora de `/api`
  (arquivos da página, Vite) não são interceptados.
- **Disciplinas:** `GET /subjects/:id` existe **só no mock**, porque `get_subject` ainda não foi
  criada no Supabase (ver [`05-melhorias-futuras.md`](05-melhorias-futuras.md), item 7): a tela
  `/disciplinas/:subjectId` só funciona com `VITE_USE_MOCKS=true`. Todas as disciplinas da lista
  têm detalhe, os assuntos saem ordenados por `number`, `materialsCount` é a soma dos materiais
  dos subassuntos, e os `fileUrl` apontam para arquivos que não existem no projeto.
- **Simulados:** todos os simulados da lista têm detalhe. O simulado integrado usa todas as
  questões do banco do mock; os demais usam as questões da sua disciplina, e `questionCount`
  é calculado a partir delas. `attemptsCount` é contado em memória e volta a zero quando a página
  é recarregada.
- **Correção:** `multiple_answer` só é correta com exatamente as alternativas corretas;
  `single_choice` e `drag_and_drop` exigem todas as lacunas corretas. Uma dissertativa (ou
  lacuna dissertativa) idêntica à referência, ignorando maiúsculas e espaços extras, é
  correta; caso contrário vira `self_review` (ver
  [`05-melhorias-futuras.md`](05-melhorias-futuras.md), item 5).
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
5. No Supabase, crie uma migration nova (`npx supabase migration new <nome>`) com a função que
   devolve o mesmo JSON, e chame-a no adaptador em `src/services/api/supabase/` com `callRpc`.
   Siga as regras de acesso de [`06-modelagem-de-dados.md`](06-modelagem-de-dados.md).
6. Atualize este documento.

Prefira mudanças aditivas (novos campos opcionais, novos endpoints). Trate qualquer coisa
listada como incompatível em [1.4](#14-validação-de-resposta-e-compatibilidade) como algo
que exige coordenação.
