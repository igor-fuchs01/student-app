# Modelagem de Dados

A modelagem de dados é descrita em três níveis, do mais abstrato ao mais concreto:

| Nível | O que responde | Onde está |
|---|---|---|
| **Conceitual** | *O que* o sistema precisa guardar, na linguagem do domínio | [Seção 1](#1-modelo-conceitual) |
| **Lógico** | *Como* isso vira tabelas, colunas, chaves e restrições no modelo relacional | [Seção 2](#2-modelo-lógico) |
| **Físico** | As migrations do PostgreSQL no Supabase (tipos, índices, views, regras de acesso e funções) | Pasta [`supabase/migrations/`](../supabase/migrations/) na raiz do projeto |

O escopo é **somente o MVP**: o necessário para os contratos implementados em
[`04-contratos-de-api.md`](04-contratos-de-api.md) e para os critérios de aceite em
[`99-criterios-de-aceite-mvp.md`](99-criterios-de-aceite-mvp.md). O que ficou de fora e por
quê está na [seção 3](#3-fora-do-mvp).

O backend é o [Supabase](https://supabase.com/): o banco PostgreSQL, o login (Supabase Auth) e as
funções que o app chama ficam nele ([`03-arquitetura-tecnica.md`](03-arquitetura-tecnica.md)).

### Arquivos

A documentação fica aqui em `docs/`; o banco é um projeto [Supabase](https://supabase.com/) na
pasta `supabase/`:

| Arquivo | Para que serve |
|---|---|
| [`supabase/migrations/`](../supabase/migrations/) | O modelo físico, uma migration por assunto, aplicadas nesta ordem: `schemas` (schema `private` e privilégios padrão), `enums`, `students`, `content` (disciplina → material), `questions`, `quizzes` (simulados), `attempts` (tentativas, respostas e dias de estudo), `views`, `row_level_security`, `grants`, `drop_old_home_data` (remove as provas agendadas e a view de desempenho por assunto que só a tela de Início antiga usava), `exercises` (`quizzes.kind` e `quizzes.topic_id` para as listas de exercícios, e `quizzesCompleted` contando só simulados) `drop_integrated_quizzes` (remove o simulado integrado: some `subject_scope` e `subject_id` passa a ser obrigatório) e `available_logins` (temporária: os códigos de acesso que um aluno pode usar uma vez para criar a própria senha). Cada tabela leva os próprios índices. Não há função de API nem JSON no banco: os endpoints são edge functions. Elas substituíram o baseline único e a migration de rate limit, que nunca tinham ido para produção. |
| [`supabase/functions/`](../supabase/functions/) | Edge functions (Deno + TypeScript): `submit-quiz-attempt` e o CORS compartilhado em `_shared/cors.ts`. Veja [`04-contratos-de-api.md`](04-contratos-de-api.md#edge-functions-e-cors). |
| [`supabase/seed.sql`](../supabase/seed.sql) | Dados mínimos para testar localmente: 2 contas de aluno (códigos `demo0001` e `demo0002`, senha `123456`), 1 disciplina com 2 assuntos, 3 subassuntos, 1 material, uma questão de cada tipo, 1 simulado, 1 tentativa enviada e os códigos de primeiro acesso `novo0001`, `novo0002` e `novo0003`, ainda disponíveis. |
| [`supabase/scripts/add-available-logins.sql`](../supabase/scripts/add-available-logins.sql) | Script de operador (temporário): gera códigos de acesso aleatórios (30 por padrão, com 10 caracteres de um alfabeto de 32 sem `i`, `l`, `0` e `1`), grava em `available_logins` e devolve a lista para distribuir aos alunos no primeiro acesso. Veja [`POST /auth/register`](04-contratos-de-api.md#post-authregister). |
| [`supabase/config.toml`](../supabase/config.toml) | Configuração do projeto local, com o cadastro público desligado e o runtime de edge functions ligado. |

### Rodando o banco localmente

É preciso ter o [Docker](https://www.docker.com/products/docker-desktop/) aberto: o Supabase CLI
sobe o banco, o login e a API em containers. Os comandos rodam a partir da raiz do projeto.

```bash
npx supabase start      # sobe tudo; na primeira vez aplica as migrations e o seed
npx supabase status     # mostra a URL da API e a publishable key para o .env.development
npx supabase db reset   # recria o banco do zero: migrations + seed
npx supabase stop       # desliga os containers
```

O painel (Supabase Studio) fica em `http://127.0.0.1:54323`, e o banco aceita conexão direta em
`postgresql://postgres:postgres@127.0.0.1:54322/postgres`.

Sobem os containers do banco, login, API REST, gateway, runtime de edge functions e painel. Os
serviços que o projeto não usa (Storage, Realtime, e-mail de teste e logs) estão desligados no
`config.toml`. Para servir as edge functions localmente:

```bash
cp supabase/functions/.env.example supabase/functions/.env
npx supabase functions serve --env-file supabase/functions/.env
```

Toda mudança no banco é uma **migration nova** (`npx supabase migration new <nome>`), nunca a
edição de uma migration já aplicada. A divisão atual só pôde reescrever o histórico porque nada
tinha sido publicado ainda; a partir da primeira publicação, a regra vale sem exceção. Para
publicar no projeto hospedado, use `npx supabase link`, `npx supabase db push`,
`npx supabase functions deploy submit-quiz-attempt` e
`npx supabase secrets set ALLOWED_ORIGINS=<origens do app>` (passo a passo em
[`07-publicacao-no-supabase.md`](07-publicacao-no-supabase.md)). Se o projeto hospedado já registrou
as migrations antigas, marque-as como revertidas antes do push:
`npx supabase migration repair --status reverted 20260923000000 20260923000100` (e recrie o banco
hospedado, já que o esquema dele é o antigo).

### Como o app acessa o banco

Com `npm run dev`, os módulos `*Api` chamam o Supabase pelo SDK; com `npm run mock`, continuam
usando o servidor mock. O app não consulta tabelas nem chama funções do banco: cada endpoint do
contrato é uma edge function (`supabase/functions/`) que lê as tabelas e views por uma conexão
direta com o Postgres e monta o JSON em TypeScript. O banco não gera nem guarda JSON.

| Contrato ([`04-contratos-de-api.md`](04-contratos-de-api.md)) | No Supabase |
|---|---|
| `POST /auth/login` | `supabase.auth.signInWithPassword()` com o e-mail `<código>@alunos.student-app.invalid`, seguida de `get-current-student` |
| `POST /auth/logout` | `supabase.auth.signOut()` |
| `GET /dashboard` | `get-dashboard` |
| `GET /subjects` | `list-subjects` |
| `GET /subjects/:id` | `get-subject?id=` |
| `GET /quizzes` | `list-quizzes` |
| `GET /exercises` | `list-exercises?topicId=` |
| `GET /quizzes/:id` | `get-quiz?id=` |
| `POST /quizzes/:id/attempts` | `submit-quiz-attempt` |
| `GET /ranking` | `get-ranking` |
| `GET /ranking/activity` | `get-activity-calendar?month=` |
| `POST /auth/register` | `register-student` (temporário, sem JWT) |

A chave do Supabase usada pelo front é pública, porque vai no navegador. Qualquer pessoa consegue
chamar a API sem passar pelo app, então a segurança fica em camadas:

- **As edge functions são a API inteira.** Cada uma valida o JWT do aluno, acha o aluno em
  `students` e filtra toda consulta por ele. `anon` e `authenticated` não têm privilégio em
  nenhuma tabela, sequência ou função, então `GET /rest/v1/students` responde 403 e não existe
  RPC nenhuma para chamar. As views e as funções auxiliares ficam no schema `private`, que não
  entra em `[api] schemas` do `config.toml` — nem em Exposed schemas, o equivalente no painel do
  projeto hospedado. Views ignoram o RLS, e é por isso que nenhuma fica em `public`.
- **Conexão das edge functions.** Elas usam `SUPABASE_DB_URL` com a role `postgres`, que ignora o
  RLS; por isso o aluno sai sempre do token, nunca de um parâmetro do corpo. As consultas usam
  parâmetros (`sql` do driver `postgres`), nunca SQL montado com texto.
- **Fechado por padrão.** O Supabase concede automaticamente às roles da API tudo que `postgres`
  cria em `public`; `ALTER DEFAULT PRIVILEGES` cancela essa concessão, então uma tabela ou função
  criada depois nasce inalcançável.
- **RLS como segunda camada.** Todas as tabelas têm RLS, e tabela sem política não devolve nenhuma
  linha: o aluno só leria as próprias linhas (perfil, tentativas, respostas e dias de estudo) e o
  conteúdo sem gabarito, e as tabelas de questões não têm política nenhuma. Nada do app depende
  disso hoje — a camada existe para que um `GRANT` dado por engano continue não vazando linha.
- **Nenhuma escrita direta.** Não existe política de `INSERT`, `UPDATE` ou `DELETE`. O envio de uma
  prova passa pela edge function `submit-quiz-attempt`, que valida o formato com zod, confere cada
  id contra o gabarito, corrige e grava tudo numa transação. O ranking devolve só id e sequência
  dos outros alunos, nunca nota.
- **Sem dados pessoais (LGPD).** As contas são criadas pela instituição, sem cadastro público. O
  aluno entra com um código de acesso gerado pela instituição e a senha, validados pelo Supabase
  Auth, que guarda o código como o e-mail `<código>@alunos.student-app.invalid` (domínio
  reservado, nunca recebe mensagem). `students` não tem nome nem e-mail: o nome que o app mostra é
  digitado pelo aluno e fica só no navegador.
- **Primeiro acesso (temporário).** Enquanto a instituição não cria as contas já com senha, o
  operador cadastra códigos aleatórios em `available_logins` e o aluno cria a própria senha pela
  edge function `register-student`, a única sem JWT. A tabela tem RLS sem política e nenhum
  privilégio para `anon` e `authenticated`, então um código ainda disponível nunca sai pela API.
  Como quem digita um código disponível primeiro fica com a conta, os códigos precisam ser longos
  e aleatórios. Depois de usado, o código aponta para a conta criada (`auth_user_id`, a mesma de
  `students.auth_user_id`); apagar a conta deixa o campo nulo, mas o código continua usado e nunca
  vai para outro aluno.
- **Ainda em aberto.** `get-quiz` devolve o gabarito junto com as questões, porque o contrato atual
  do `QuizDetail` inclui essas respostas ([`05-melhorias-futuras.md`](05-melhorias-futuras.md),
  item 2).

---

## 1. Modelo conceitual

O modelo conceitual descreve as **entidades** (coisas sobre as quais o sistema guarda informação),
os **relacionamentos** entre elas e as **cardinalidades** (quantos de um se ligam a quantos do
outro). Ele não fala de banco de dados, tipos ou chaves: deve poder ser lido por qualquer pessoa
da equipe, inclusive quem não programa.

### 1.1 Entidades

| Entidade | O que representa |
|---|---|
| **Aluno** | Conta de estudante, pré-provisionada pelo responsável (não há cadastro público), identificada só por um código de acesso — sem nome nem e-mail. Tem uma meta semanal de questões. |
| **Sessão** | Um login ativo do aluno, controlado pelo Supabase Auth. É encerrada no logout. |
| **Disciplina** | Matéria do curso, ex.: Banco de Dados. |
| **Assunto** | Tema dentro de uma disciplina, ex.: Normalização. Corresponde a uma aula da ementa, com um número próprio, e é a unidade usada para identificar dificuldades. |
| **Subassunto** | Recorte de um assunto, ex.: Formas Normais. Tem um resumo curto e pontos-chave, para o aluno revisar antes de estudar ou fazer um simulado. |
| **Material** | Material didático (PDF) de um subassunto. |
| **Questão** | Item de prática, de um dos seis tipos do contrato (múltipla escolha, múltiplas alternativas, seleção única, drag and drop, dissertativa e dissertativa com lacunas). |
| **Alternativa** | Opção que o aluno pode escolher: de uma questão (múltipla escolha e múltiplas alternativas) ou de uma lacuna (seleção única). |
| **Lacuna** | Espaço `{{id}}` no texto de uma questão, preenchido por seleção, por texto ou arrastando um termo. |
| **Termo** | Item arrastável de uma questão de drag and drop. |
| **Simulado** | Conjunto ordenado de questões de uma disciplina, com duração e dificuldade. Não existe simulado integrado. |
| **Lista de exercícios** | Um simulado de tipo `exercise`: questões de um único assunto, sem duração. Fica na mesma tabela e usa as mesmas tentativas, correção e resultado. |
| **Tentativa** | Envio de um simulado por um aluno. |
| **Resposta** | O que o aluno respondeu em uma questão de uma tentativa, com o resultado da correção. |
| **Dia de estudo** | Dia em que o aluno teve atividade. É a base do streak. |

### 1.2 Relacionamentos

| Relacionamento | Cardinalidade | Leitura |
|---|---|---|
| Aluno — Sessão | 1 : N | Um aluno pode ter várias sessões; cada sessão é de um aluno. |
| Aluno — Tentativa | 1 : N | Um aluno faz várias tentativas; cada tentativa é de um aluno. |
| Aluno — Dia de estudo | 1 : N | Um aluno registra vários dias de estudo. |
| Disciplina — Assunto | 1 : N | Uma disciplina organiza vários assuntos; cada assunto pertence a uma disciplina. |
| Assunto — Subassunto | 1 : N | Um assunto se divide em vários subassuntos; cada subassunto pertence a um assunto. |
| Subassunto — Material | 1 : N | Um subassunto tem vários materiais. |
| Assunto — Questão | 1 : N | Toda questão tem exatamente um assunto e, por meio dele, uma disciplina ([`02-regras-de-negocio.md`](02-regras-de-negocio.md) §1). |
| Questão — Alternativa | 1 : N | Só nos tipos múltipla escolha e múltiplas alternativas. |
| Questão — Lacuna | 1 : N | Só nos tipos seleção única, drag and drop e dissertativa com lacunas. |
| Lacuna — Alternativa | 1 : N | Só na seleção única. Uma alternativa pertence a uma questão **ou** a uma lacuna, nunca às duas. |
| Questão — Termo | 1 : N | Só no drag and drop. |
| Termo — Lacuna | 1 : N | No drag and drop, cada lacuna tem um termo correto. |
| Disciplina — Simulado | 1 : N | Todo simulado (e toda lista de exercícios) é de exatamente uma disciplina. |
| Assunto — Lista de exercícios | 1 : N | Uma lista de exercícios é de exatamente um assunto (`quizzes.topic_id`); um assunto pode ter várias listas. Um simulado (`kind = 'exam'`) não tem assunto. |
| Simulado — Questão | N : M | Um simulado tem pelo menos uma questão; uma questão pode estar em vários simulados. O relacionamento tem um atributo: a **ordem** da questão no simulado. |
| Simulado — Tentativa | 1 : N | Sem limite: o aluno refaz o simulado quantas vezes quiser, e cada envio vira uma tentativa. |
| Tentativa — Questão | N : M, via **Resposta** | Resposta é uma entidade associativa: no máximo uma por questão em cada tentativa. Questões sem resposta contam como não respondidas. |

### 1.3 Diagrama conceitual

```mermaid
erDiagram
    ALUNO ||--o{ SESSAO : "abre"
    ALUNO ||--o{ TENTATIVA : "realiza"
    ALUNO ||--o{ DIA_DE_ESTUDO : "registra"

    DISCIPLINA ||--o{ ASSUNTO : "organiza"
    ASSUNTO ||--o{ SUBASSUNTO : "divide-se em"
    SUBASSUNTO ||--o{ MATERIAL : "possui"
    ASSUNTO ||--o{ QUESTAO : "classifica"

    QUESTAO |o--o{ ALTERNATIVA : "oferece"
    QUESTAO ||--o{ LACUNA : "contém"
    LACUNA |o--o{ ALTERNATIVA : "oferece"
    QUESTAO ||--o{ TERMO : "oferece"
    TERMO |o--o{ LACUNA : "preenche corretamente"

    DISCIPLINA |o--o{ SIMULADO : "delimita"
    SIMULADO }o--|{ QUESTAO : "é composto por"
    SIMULADO ||--o{ TENTATIVA : "gera"
    TENTATIVA ||--o{ RESPOSTA : "contém"
    QUESTAO ||--o{ RESPOSTA : "é respondida em"
```

Como ler a notação (pé de galinha): `||` = exatamente um, `|o` = zero ou um, `o{` = zero ou
muitos, `|{` = um ou muitos. O símbolo fica do lado da entidade que ele quantifica.

### 1.4 Informações derivadas

Várias informações que o aluno vê **não são guardadas**, porque podem ser calculadas a partir de
outras entidades. Guardá-las criaria duas fontes de verdade que podem divergir — por exemplo, a
nota de uma tentativa ficaria errada quando uma dissertativa pendente fosse corrigida.

| Informação | Calculada a partir de |
|---|---|
| Quantidade de materiais e questões da disciplina | Material, Questão |
| Preparação na disciplina e dificuldade por assunto | Resposta |
| Tentativas já realizadas | Tentativa |
| Resultado da tentativa (acertos, erros, não respondidas, nota, desempenho por disciplina) | Resposta, Simulado |
| Streak e posição no ranking | Dia de estudo |
| Meta semanal concluída, questões respondidas, simulados concluídos | Resposta, Tentativa |

---

## 2. Modelo lógico

O modelo lógico traduz o conceitual para o **modelo relacional**: cada entidade vira uma ou mais
tabelas, cada atributo vira uma coluna com tipo, e cada relacionamento vira uma chave estrangeira
(FK) ou uma tabela associativa. Detalhes específicos do PostgreSQL (índices, extensões, texto das
views, regras de acesso) ficam no modelo físico, em [`supabase/migrations/`](../supabase/migrations/).

### 2.1 Das entidades para as tabelas

| Entidade (conceitual) | Tabela (lógico) |
|---|---|
| Aluno | `students` |
| Sessão | Supabase Auth (`auth.users` e as sessões dele), ligado ao aluno por `students.auth_user_id` |
| Disciplina | `subjects` |
| Assunto | `topics` |
| Subassunto | `subtopics`, com os pontos-chave em `subtopic_key_points` |
| Material | `materials` |
| Questão | `questions` |
| Alternativa | `question_options` (de questão) e `question_blank_options` (de lacuna) |
| Lacuna | `question_blanks` (seleção única e dissertativa) e `question_slots` (drag and drop) |
| Termo | `question_terms` |
| Simulado e Lista de exercícios | `quizzes`, separados por `kind` (`exam` ou `exercise`) |
| Simulado — Questão (N : M) | `quiz_questions` |
| Tentativa | `quiz_attempts` |
| Resposta | `quiz_attempt_answers`, com os valores múltiplos em `quiz_attempt_answer_options`, `quiz_attempt_answer_blanks` e `quiz_attempt_answer_slots` |
| Dia de estudo | `student_activity_days` |
| Código de acesso disponível (temporário) | `available_logins` |

Nomes de tabelas e colunas em inglês, seguindo a convenção de código do projeto.

### 2.2 Decisões de mapeamento

- **Chaves primárias.** Todas as tabelas usam `id int` gerado automaticamente (identity). As
  exceções são as tabelas cuja chave natural já é única: `quiz_questions` (`quiz_id`,
  `question_id`) e `student_activity_days` (`student_id`, `activity_date`). O contrato trata ids
  como string, então a API envia o número como texto (ex.: `"12"`).
- **Relacionamentos 1 : N** viram uma FK na tabela do lado N. `ON DELETE CASCADE` só é usado quando
  o filho não existe sem o pai (alternativas de uma questão, respostas de uma tentativa).
- **Login fica com o Supabase Auth.** O banco não guarda senha nem token: cada aluno aponta para um
  usuário do Auth por `students.auth_user_id` (uuid, único). É o único uuid do modelo, obrigatório
  porque `auth.users.id` e `auth.uid()` são uuid; todo id próprio da aplicação é inteiro. Apagar o
  usuário apaga o aluno.
- **Lista de exercícios na tabela de simulados.** Ela só difere do simulado por ter um assunto e
  não ter duração, então fica em `quizzes` com `kind = 'exercise'`. `CHECK`s garantem que
  `topic_id` exista só nela e que `duration_minutes` seja nulo só nela; como todo quiz, ela tem
  `subject_id` obrigatório. Assim tentativas, respostas e correção servem aos dois
  sem tabelas paralelas.
- **Relacionamento N : M** entre Simulado e Questão vira a tabela associativa `quiz_questions`, que
  também guarda o atributo do relacionamento (`order_index`).
- **Tipos de questão em uma única tabela.** Os seis tipos diferem em poucas colunas (`prompt`,
  `template`, `explanation`, `max_length`, `reference_answer`), então ficam em `questions` com a
  coluna `type`. Restrições `CHECK` garantem que cada tipo tenha exatamente as colunas que o
  contrato exige, sem precisar de uma tabela por tipo.
- **Alternativa e Lacuna viram duas tabelas cada.** Uma alternativa de questão e uma alternativa de
  lacuna têm pais diferentes; separar mantém toda FK obrigatória (`NOT NULL`), em vez de uma
  coluna "questão **ou** lacuna" que o banco não consegue validar direito. Pelo mesmo motivo, a
  lacuna de drag and drop (`question_slots`) fica separada, porque exige um termo correto.
- **Resposta** segue a união `QuizAnswer` do contrato sem JSON no banco. As de um valor só ficam em
  `quiz_attempt_answers` (`selected_option_id` para `multiple_choice`, `essay_text` para `essay`);
  as de vários valores viram uma linha por valor em tabelas filhas: `quiz_attempt_answer_options`
  (alternativas de `multiple_answer`), `quiz_attempt_answer_blanks` (lacunas de `single_choice`,
  com a opção escolhida, e de `essay_blanks`, com o texto) e `quiz_attempt_answer_slots` (termo
  de cada lacuna de `drag_and_drop`). Cada valor tem FK para o que respondeu, então o banco garante
  que ele existe. A restrição `UNIQUE (attempt_id, question_id)` garante no máximo uma resposta por
  questão.
- **Normalização (3FN).** `questions` guarda apenas `topic_id`; a disciplina é obtida pelo assunto.
  Guardar também `subject_id` seria uma dependência transitiva e permitiria uma questão com assunto
  de Banco de Dados e disciplina de Algoritmos.
- **Estado da correção** (`review_status`) usa os três estados de
  [`02-regras-de-negocio.md`](02-regras-de-negocio.md) §6: `correct`, `incorrect` e
  `pending_review`. A API expõe `pending_review` como `self_review`
  ([`05-melhorias-futuras.md`](05-melhorias-futuras.md), item 5).
- **Meta semanal** é uma coluna de `students` (`weekly_goal_target`), porque é o único dado de
  gamificação que não pode ser calculado.
- **Informações derivadas** (seção 1.4) viram views, listadas na seção 2.4.
- **Índices.** Só recebe índice próprio a chave estrangeira que nenhuma restrição `UNIQUE` já
  indexa pela primeira coluna: o PostgreSQL não cria índice para o lado que referencia, e o
  `ON DELETE` precisa achar as linhas filhas.
- **Convenções do script.** Restrições de tabela têm nome próprio (ex.:
  `questions_statement_per_type_check`), para que o erro do banco diga qual regra falhou; toda
  chave estrangeira declara seu `ON DELETE` (`CASCADE` quando o filho não existe sem o pai,
  `RESTRICT` quando apagar o pai destruiria histórico); e cada tabela tem um `COMMENT ON TABLE`,
  então a documentação viaja junto do banco.

### 2.3 Diagrama lógico

```mermaid
erDiagram
    auth_users ||--o| students : ""
    students ||--o{ quiz_attempts : ""
    students ||--o{ student_activity_days : ""

    subjects ||--o{ topics : ""
    topics ||--o{ subtopics : ""
    subtopics ||--o{ subtopic_key_points : ""
    subtopics ||--o{ materials : ""
    topics ||--o{ questions : ""

    questions ||--o{ question_options : ""
    questions ||--o{ question_blanks : ""
    question_blanks ||--o{ question_blank_options : ""
    questions ||--o{ question_terms : ""
    questions ||--o{ question_slots : ""
    question_terms ||--o{ question_slots : ""

    subjects ||--o{ quizzes : ""
    quizzes ||--|{ quiz_questions : ""
    questions ||--o{ quiz_questions : ""
    quizzes ||--o{ quiz_attempts : ""
    quiz_attempts ||--o{ quiz_attempt_answers : ""
    questions ||--o{ quiz_attempt_answers : ""
    question_options |o--o{ quiz_attempt_answers : ""
    quiz_attempt_answers ||--o{ quiz_attempt_answer_options : ""
    question_options ||--o{ quiz_attempt_answer_options : ""
    quiz_attempt_answers ||--o{ quiz_attempt_answer_blanks : ""
    question_blanks ||--o{ quiz_attempt_answer_blanks : ""
    question_blank_options |o--o{ quiz_attempt_answer_blanks : ""
    quiz_attempt_answers ||--o{ quiz_attempt_answer_slots : ""
    question_slots ||--o{ quiz_attempt_answer_slots : ""
    question_terms ||--o{ quiz_attempt_answer_slots : ""

    auth_users |o--o| available_logins : ""

    available_logins {
        text access_code PK
        timestamptz created_at
        timestamptz claimed_at "nulo enquanto disponível"
        uuid auth_user_id UK, FK "conta criada"
    }

    auth_users {
        uuid id PK
        text email "código de acesso"
    }

    students {
        int id PK
        uuid auth_user_id UK, FK
        text course
        int weekly_goal_target
    }

    subjects {
        int id PK
        text name
        text short_label
    }

    topics {
        int id PK
        int subject_id FK
        int number
        text name
        text description
    }

    subtopics {
        int id PK
        int topic_id FK
        text name
        text summary
        int order_index
    }

    subtopic_key_points {
        int id PK
        int subtopic_id FK
        text text
        int order_index
    }

    materials {
        int id PK
        int subtopic_id FK
        text title
        text file_url
    }

    questions {
        int id PK
        int topic_id FK
        question_type type
        text prompt
        text template
        text explanation
        int max_length
        text reference_answer
    }

    question_options {
        int id PK
        int question_id FK
        text text
        boolean is_correct
        int order_index
    }

    question_blanks {
        int id PK
        int question_id FK
        text blank_key
        text reference_answer
        int order_index
    }

    question_blank_options {
        int id PK
        int blank_id FK
        text text
        boolean is_correct
        int order_index
    }

    question_terms {
        int id PK
        int question_id FK
        text text
        int order_index
    }

    question_slots {
        int id PK
        int question_id FK
        text slot_key
        int correct_term_id FK
        int order_index
    }

    quizzes {
        int id PK
        text title
        quiz_kind kind
        int subject_id FK
        int topic_id FK
        int duration_minutes
        difficulty_level difficulty
    }

    quiz_questions {
        int quiz_id PK, FK
        int question_id PK, FK
        int order_index
    }

    quiz_attempts {
        int id PK
        int quiz_id FK
        int student_id FK
        timestamptz submitted_at
    }

    quiz_attempt_answers {
        int id PK
        int attempt_id FK
        int question_id FK
        int selected_option_id FK
        text essay_text
        review_status review_status
    }

    quiz_attempt_answer_options {
        int answer_id PK, FK
        int option_id PK, FK
    }

    quiz_attempt_answer_blanks {
        int answer_id PK, FK
        int blank_id PK, FK
        int selected_option_id FK
        text text
    }

    quiz_attempt_answer_slots {
        int answer_id PK, FK
        int slot_id PK, FK
        int term_id FK
    }

    student_activity_days {
        int student_id PK, FK
        date activity_date PK
    }
```

Enums: `question_type`, `quiz_kind` (`exam`, `exercise`), `difficulty_level` (`easy`,
`medium`, `hard`) e `review_status` (`correct`, `incorrect`, `pending_review`).

### 2.4 Views (informações derivadas)

Todas ficam no schema `private` e são lidas só pelas edge functions. `private.percent(parte, total)`
concentra o arredondamento das porcentagens; cada view decide o que conta como resposta corrigida.

| View | Campo(s) do contrato |
|---|---|
| `v_subject_summary` | `Subject.materialsCount`, `Subject.questionsCount` |
| `v_student_subject_performance` | `Subject.preparationPercent` |
| `v_quiz_summary` | `QuizSummary.questionCount`, `ExerciseSummary.questionCount` |
| `v_student_streak`, `v_student_ranking` | `streakDays`, `RankingData.entries` |
| `v_student_ranking_profile` | `RankingData.profile` (`quizzesCompleted` conta só simulados), `DashboardData.streakDays` e `DashboardData.weeklyGoal` |

`QuizSummary.attemptsCount` é contado pela edge function `list-quizzes`, filtrado pelo aluno. O
`QuizResult` inteiro (contadores, `scorePercent`, `subjectPerformance` e `reviewItems`) é
calculado pela `submit-quiz-attempt` a partir das respostas que ela acabou de corrigir, com as
mesmas regras: `self_review` fica fora da nota e questão não respondida entra no denominador.
O resto do `DashboardData` depende do período e da disciplina pedidos, então a `get-dashboard`
agrega as respostas do aluno direto nas tabelas, com `private.percent` e o mesmo critério de
resposta corrigida das views.

---

## 3. Fora do MVP

Itens que existiam na primeira versão do modelo e foram removidos por não serem exigidos pelos
contratos atuais nem pelos critérios de aceite do MVP. Seguem a regra de
[`99-criterios-de-aceite-mvp.md`](99-criterios-de-aceite-mvp.md): *não implementar
funcionalidades complexas apenas porque foram mencionadas como possibilidades futuras*.

| Removido | Por quê | Quando volta |
|---|---|---|
| Vínculo questão — material | "Encontrar questões relacionadas aos assuntos" é resolvido pelo assunto. | Recomendação "revisar o material correspondente" (§9) |
| Disciplina na questão (`questions.subject_id`) | Redundante com o assunto (ver normalização, seção 2.2). | — |
| Dificuldade por questão | Só o simulado tem dificuldade no contrato; desempenho por dificuldade não está nos critérios de aceite. | Fase 4 — Desempenho |
| Provas agendadas (`scheduled_exams`) e a view `v_student_topic_performance` | A tela de Início deixou de mostrar a próxima prova e as prioridades por assunto calculadas sobre todo o histórico (migration `drop_old_home_data`). | Modo Semana de Provas (Fase 5) |
| Limite de tentativas (`quizzes.attempts_allowed`) | Não existe limite: o aluno refaz o simulado quantas vezes quiser, e o contrato passa a informar quantas tentativas ele já enviou (`QuizSummary.attemptsCount`). | — |
| Contadores e nota gravados na tentativa | Derivados das respostas (seção 1.4). | — |
| Tabela `student_stats` | Contadores derivados; a meta semanal virou coluna de `students`. | Se o ranking ficar lento, depois de medir ([`03-arquitetura-tecnica.md`](03-arquitetura-tecnica.md)) |
| Início da tentativa (`started_at`) e horário de cada resposta | O contrato atual só cria a tentativa no envio, e o cronômetro fica no cliente no MVP. | Item 1 de [`05-melhorias-futuras.md`](05-melhorias-futuras.md) |
| Colunas de auditoria (`created_at`) | Nenhum contrato ou critério usa. Sessões e expiração de login ficam com o Supabase Auth. | Painel administrativo (Fase 7) |
| Tabela `auth_tokens` e coluna `students.password_hash` | O Supabase Auth guarda senhas e sessões. | — |
| Nome e e-mail do aluno (`students.name`, `students.email`) | LGPD: o login é um código de acesso guardado no Supabase Auth e o nome fica só no navegador. | — |
