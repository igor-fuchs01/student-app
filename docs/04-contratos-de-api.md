# Contratos de API

Este documento descreve os contratos de API **atualmente implementados** pelo frontend.
A fonte da verdade é o código; atualize este documento sempre que algo abaixo mudar:

| O quê | Onde |
|---|---|
| Caminhos dos endpoints | `src/services/api/endpoints.ts` |
| Formato de request/response (schemas zod) | `src/types/auth.ts`, `src/types/dashboard.ts` |
| Códigos de erro e corpo do erro | `src/services/api/errors.ts` |
| Transporte, headers, tratamento de erro | `src/services/api/httpClient.ts` |
| Implementação do mock | `src/services/api/mocks/mockServer.ts` |

Para a superfície de API mais ampla e planejada (disciplinas, simulados, tentativas,
desempenho, etc.), veja a seção 23 de [`03-arquitetura-tecnica.md`](03-arquitetura-tecnica.md).
Apenas os endpoints listados abaixo existem hoje.

---

## 1. Convenções gerais

### 1.1 Ambientes e URL base

| Comando | Arquivo de env | Para onde vão as requisições |
|---|---|---|
| `npm run mock` | `.env.mock` | Servidor mock no navegador — nenhuma requisição de rede |
| `npm run dev` | `.env.development` | `VITE_API_BASE_URL` (hoje, a URL fictícia `https://api.homologacao.student-app.example/v1`) |

Todo caminho descrito neste documento é relativo à URL base. Exemplo:
`POST /auth/login` → `POST https://api.homologacao.student-app.example/v1/auth/login`.

Quando os mocks estão desativados, `VITE_API_BASE_URL` é obrigatória e precisa ser uma
URL válida; caso contrário a aplicação se recusa a iniciar. Barras finais são removidas.

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

---

## 3. Endpoints e modelos

### `POST /auth/login`

Autentica uma conta de aluno pré-provisionada (não há cadastro público).

**Autenticação:** não exigida. O cliente nunca envia um header `Authorization` aqui.

**Corpo da requisição** — `LoginCredentials`

| Campo | Tipo | Regras | Descrição |
|---|---|---|---|
| `identifier` | string | Obrigatório. Sofre trim; não pode ficar vazio após o trim. | Matrícula do aluno ou e-mail institucional. A comparação do e-mail não diferencia maiúsculas/minúsculas. |
| `password` | string | Obrigatório. Não pode ser vazio. | Senha da conta. |

```json
{
  "identifier": "20231234",
  "password": "123456"
}
```

**Respostas**

| Status | Corpo | Quando |
|---|---|---|
| `200` | [`AuthSession`](#32-authsession) | As credenciais são válidas. |
| `400` | Erro, código `VALIDATION_ERROR` | Corpo ausente ou inválido, identificador em branco, ou senha vazia. |
| `401` | Erro, código `INVALID_CREDENTIALS` | Nenhuma conta corresponde ao identificador, ou a senha está errada. |

```json
{
  "token": "eyJhbGciOi...",
  "user": {
    "id": "u_marina",
    "name": "Marina Alves",
    "email": "marina@aluno.ifpr.edu.br",
    "registrationId": "20231234",
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

### 3.1 `StudentUser`

| Campo | Tipo | Regras |
|---|---|---|
| `id` | string | Não vazio. Identificador único e estável do aluno. |
| `name` | string | Não vazio. Nome completo; a UI cumprimenta o aluno pela primeira palavra. |
| `email` | string | Não vazio. E-mail institucional. |
| `registrationId` | string | Não vazio. Matrícula. |
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

---

## 4. Erros

### 4.1 Corpo do erro

Toda resposta não-`2xx` do servidor deve usar este corpo:

```json
{
  "code": "INVALID_CREDENTIALS",
  "message": "Matrícula/e-mail ou senha inválidos."
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
| `INVALID_CREDENTIALS` | `401` | Servidor | Falha no login: identificador desconhecido ou senha errada. |
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
- **Requisições canceladas** rejeitam com um `AbortError` padrão, não um `ApiError`, e
  não são exibidas como erro.
- **Corpos vazios** só são válidos para endpoints documentados como sem corpo de resposta (`204`).

---

## 5. Comportamento do servidor mock

Com `npm run mock`, `src/services/api/mocks/mockServer.ts` implementa todos os endpoints
acima no navegador, com os mesmos status e corpos de erro. Particularidades do mock:

- **Latência:** toda resposta é atrasada por `VITE_MOCK_DELAY_MS` (padrão `500` ms).
- **Conta de demonstração:** matrícula `20231234` ou e-mail `marina@aluno.ifpr.edu.br`,
  senha `123456`.
- **Formato do token:** `mock.<userId>.<uuid>`. Esse formato existe apenas no mock; tokens
  reais devem ser tratados como opacos.
- **Rotas desconhecidas** retornam `404` com código `NOT_FOUND`.

---

## 6. Alterando ou adicionando um contrato

1. Adicione ou altere o caminho em `src/services/api/endpoints.ts`.
2. Defina o formato de request/response como um schema zod em `src/types/` e exporte
   seu tipo `z.infer`.
3. Adicione ou atualize o método no módulo `*Api` da feature, passando o schema.
4. Implemente a rota em `src/services/api/mocks/mockServer.ts`.
5. Atualize este documento.

Prefira mudanças aditivas (novos campos opcionais, novos endpoints). Trate qualquer coisa
listada como incompatível em [1.4](#14-validação-de-resposta-e-compatibilidade) como algo
que exige coordenação.
