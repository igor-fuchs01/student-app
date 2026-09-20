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
| [`supabase/migrations/`](../supabase/migrations/) | O modelo físico, aplicado em ordem: o schema, já com o vínculo de cada aluno ao Supabase Auth (`…_initial_schema.sql`), as regras de acesso (`…_auth_and_security.sql`) e as funções chamadas pelo app (`…_api_read_functions.sql` e `…_submit_quiz_attempt.sql`). |
| [`supabase/seed.sql`](../supabase/seed.sql) | Dados mínimos para testar localmente: 2 contas de aluno (senha `123456`), 1 disciplina com 2 assuntos, 1 material, uma questão de cada tipo, 1 simulado e 1 tentativa enviada. |
| [`supabase/config.toml`](../supabase/config.toml) | Configuração do projeto local, com o cadastro público desligado. |

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

Sobem 6 containers: banco, login, API REST, gateway e o painel. Os serviços que o projeto não usa
(Storage, Realtime, Edge Functions, e-mail de teste e logs) estão desligados no `config.toml`.

Toda mudança no banco é uma **migration nova** (`npx supabase migration new <nome>`), nunca a
edição de uma migration já aplicada. Para publicar no projeto hospedado, use `npx supabase link` e
depois `npx supabase db push`.

### Como o app acessa o banco

Com `npm run dev`, os módulos `*Api` chamam o Supabase pelo SDK; com `npm run mock`, continuam
usando o servidor mock. O app não consulta tabelas diretamente: cada endpoint do contrato é uma
função no banco que devolve o mesmo JSON.

| Contrato ([`04-contratos-de-api.md`](04-contratos-de-api.md)) | No Supabase |
|---|---|
| `POST /auth/login` | `supabase.auth.signInWithPassword()`, seguida de `get_current_student()` |
| `POST /auth/logout` | `supabase.auth.signOut()` |
| `GET /dashboard` | `get_dashboard()` |
| `GET /subjects` | `list_subjects()` |
| `GET /quizzes` | `list_quizzes()` |
| `GET /quizzes/:id` | `get_quiz(p_quiz_id)` |
| `POST /quizzes/:id/attempts` | `submit_quiz_attempt(p_quiz_id, p_answers)` |
| `GET /ranking` | `get_ranking()` |

A chave do Supabase usada pelo front é pública, porque vai no navegador. Qualquer pessoa consegue
chamar a API sem passar pelo app, então a segurança fica no banco:

- **RLS em todas as tabelas.** Tabela sem política não devolve nenhuma linha. O aluno só lê as
  próprias linhas (perfil, tentativas, respostas e dias de estudo) e o conteúdo sem gabarito. As
  tabelas de questões não têm política de leitura.
- **Nenhuma escrita direta.** Não existe política de `INSERT`, `UPDATE` ou `DELETE`. O envio de uma
  prova passa por `submit_quiz_attempt`, que valida cada id recebido e corrige no servidor.
- **Views fechadas.** Views ignoram o RLS, então o app não acessa nenhuma. Os dados delas só saem
  pelas funções, com os campos permitidos: o ranking nunca expõe notas.
- **Funções protegidas.** São `SECURITY DEFINER` com `search_path` vazio e nomes completos,
  identificam o aluno só por `auth.uid()` (nunca por um parâmetro) e não montam SQL com texto.
  Funções auxiliares não podem ser chamadas pelo app.
- **Login.** As contas são criadas pela instituição, sem cadastro público. O aluno entra com o
  e-mail institucional e a senha, validados pelo Supabase Auth.
- **Ainda em aberto.** `get_quiz` devolve o gabarito junto com as questões, porque o contrato atual
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
| **Aluno** | Conta de estudante, pré-provisionada pelo responsável (não há cadastro público). Tem uma meta semanal de questões. |
| **Sessão** | Um login ativo do aluno, controlado pelo Supabase Auth. É encerrada no logout. |
| **Disciplina** | Matéria do curso, ex.: Banco de Dados. |
| **Assunto** | Tema dentro de uma disciplina, ex.: Normalização. É a unidade usada para identificar dificuldades. |
| **Material** | Material didático (PDF) de um assunto. |
| **Questão** | Item de prática, de um dos seis tipos do contrato (múltipla escolha, múltiplas alternativas, seleção única, drag and drop, dissertativa e dissertativa com lacunas). |
| **Alternativa** | Opção que o aluno pode escolher: de uma questão (múltipla escolha e múltiplas alternativas) ou de uma lacuna (seleção única). |
| **Lacuna** | Espaço `{{id}}` no texto de uma questão, preenchido por seleção, por texto ou arrastando um termo. |
| **Termo** | Item arrastável de uma questão de drag and drop. |
| **Simulado** | Conjunto ordenado de questões, com duração e dificuldade. Pode ser de uma disciplina ou integrado. |
| **Tentativa** | Envio de um simulado por um aluno. |
| **Resposta** | O que o aluno respondeu em uma questão de uma tentativa, com o resultado da correção. |
| **Prova** | Próxima avaliação de uma disciplina, exibida na tela de Início. |
| **Dia de estudo** | Dia em que o aluno teve atividade. É a base do streak. |

### 1.2 Relacionamentos

| Relacionamento | Cardinalidade | Leitura |
|---|---|---|
| Aluno — Sessão | 1 : N | Um aluno pode ter várias sessões; cada sessão é de um aluno. |
| Aluno — Tentativa | 1 : N | Um aluno faz várias tentativas; cada tentativa é de um aluno. |
| Aluno — Dia de estudo | 1 : N | Um aluno registra vários dias de estudo. |
| Disciplina — Assunto | 1 : N | Uma disciplina organiza vários assuntos; cada assunto pertence a uma disciplina. |
| Assunto — Material | 1 : N | Um assunto tem vários materiais. |
| Assunto — Questão | 1 : N | Toda questão tem exatamente um assunto e, por meio dele, uma disciplina ([`02-regras-de-negocio.md`](02-regras-de-negocio.md) §1). |
| Questão — Alternativa | 1 : N | Só nos tipos múltipla escolha e múltiplas alternativas. |
| Questão — Lacuna | 1 : N | Só nos tipos seleção única, drag and drop e dissertativa com lacunas. |
| Lacuna — Alternativa | 1 : N | Só na seleção única. Uma alternativa pertence a uma questão **ou** a uma lacuna, nunca às duas. |
| Questão — Termo | 1 : N | Só no drag and drop. |
| Termo — Lacuna | 1 : N | No drag and drop, cada lacuna tem um termo correto. |
| Disciplina — Simulado | 0..1 : N | Um simulado é de uma disciplina ou é integrado (sem disciplina). |
| Simulado — Questão | N : M | Um simulado tem pelo menos uma questão; uma questão pode estar em vários simulados. O relacionamento tem um atributo: a **ordem** da questão no simulado. |
| Simulado — Tentativa | 1 : N | Sem limite: o aluno refaz o simulado quantas vezes quiser, e cada envio vira uma tentativa. |
| Tentativa — Questão | N : M, via **Resposta** | Resposta é uma entidade associativa: no máximo uma por questão em cada tentativa. Questões sem resposta contam como não respondidas. |
| Disciplina — Prova | 1 : N | Uma disciplina pode ter várias provas agendadas. |

### 1.3 Diagrama conceitual

```mermaid
erDiagram
    ALUNO ||--o{ SESSAO : "abre"
    ALUNO ||--o{ TENTATIVA : "realiza"
    ALUNO ||--o{ DIA_DE_ESTUDO : "registra"

    DISCIPLINA ||--o{ ASSUNTO : "organiza"
    ASSUNTO ||--o{ MATERIAL : "possui"
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

    DISCIPLINA ||--o{ PROVA : "tem"
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
| Material | `materials` |
| Questão | `questions` |
| Alternativa | `question_options` (de questão) e `question_blank_options` (de lacuna) |
| Lacuna | `question_blanks` (seleção única e dissertativa) e `question_slots` (drag and drop) |
| Termo | `question_terms` |
| Simulado | `quizzes` |
| Simulado — Questão (N : M) | `quiz_questions` |
| Tentativa | `quiz_attempts` |
| Resposta | `quiz_attempt_answers` |
| Prova | `scheduled_exams` |
| Dia de estudo | `student_activity_days` |

Nomes de tabelas e colunas em inglês, seguindo a convenção de código do projeto.

### 2.2 Decisões de mapeamento

- **Chaves primárias.** Todas as tabelas usam `id int` gerado automaticamente (identity). As
  exceções são as tabelas cuja chave natural já é única: `quiz_questions` (`quiz_id`,
  `question_id`) e `student_activity_days` (`student_id`, `activity_date`). O contrato trata ids
  como string, então a API envia o número como texto (ex.: `"12"`).
- **Relacionamentos 1 : N** viram uma FK na tabela do lado N. `ON DELETE CASCADE` só é usado quando
  o filho não existe sem o pai (alternativas de uma questão, respostas de uma tentativa).
- **Login fica com o Supabase Auth.** O banco não guarda senha nem token: cada aluno aponta para um
  usuário do Auth por `students.auth_user_id` (uuid, único). Apagar o usuário apaga o aluno.
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
- **Resposta** segue a união `QuizAnswer` do contrato: uma coluna para cada forma de resposta, e só
  a do tipo da questão é preenchida. Respostas com vários valores (`selected_option_ids`,
  `blank_answers`, `slot_answers`) usam `jsonb`, porque são sempre lidas e gravadas inteiras. A
  restrição `UNIQUE (attempt_id, question_id)` garante no máximo uma resposta por questão.
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
    topics ||--o{ materials : ""
    topics ||--o{ questions : ""

    questions ||--o{ question_options : ""
    questions ||--o{ question_blanks : ""
    question_blanks ||--o{ question_blank_options : ""
    questions ||--o{ question_terms : ""
    questions ||--o{ question_slots : ""
    question_terms ||--o{ question_slots : ""

    subjects |o--o{ quizzes : ""
    quizzes ||--|{ quiz_questions : ""
    questions ||--o{ quiz_questions : ""
    quizzes ||--o{ quiz_attempts : ""
    quiz_attempts ||--o{ quiz_attempt_answers : ""
    questions ||--o{ quiz_attempt_answers : ""
    question_options |o--o{ quiz_attempt_answers : ""

    subjects ||--o{ scheduled_exams : ""

    auth_users {
        uuid id PK
        text email
    }

    students {
        int id PK
        uuid auth_user_id UK, FK
        text name
        citext email UK
        text registration_id UK
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
        text name
    }

    materials {
        int id PK
        int topic_id FK
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
        quiz_subject_scope subject_scope
        int subject_id FK
        int duration_minutes
        difficulty_level difficulty
    }

    quiz_questions {
        int quiz_id PK, FK
        int question_id PK, FK
        int order_index
    }

    scheduled_exams {
        int id PK
        int subject_id FK
        date exam_date
        text note
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
        jsonb selected_option_ids
        text essay_text
        jsonb blank_answers
        jsonb slot_answers
        review_status review_status
    }

    student_activity_days {
        int student_id PK, FK
        date activity_date PK
    }
```

Enums: `question_type`, `quiz_subject_scope` (`single`, `all`), `difficulty_level` (`easy`,
`medium`, `hard`) e `review_status` (`correct`, `incorrect`, `pending_review`).

### 2.4 Views (informações derivadas)

| View | Campo(s) do contrato |
|---|---|
| `v_subject_summary` | `Subject.materialsCount`, `Subject.questionsCount` |
| `v_student_subject_performance` | `Subject.preparationPercent`, `NextExam.overallPreparation` |
| `v_student_topic_performance` | `NextExam.priorities` (o nível alta/média/baixa é um corte aplicado pela aplicação) |
| `v_quiz_summary` | `QuizSummary.questionCount` |
| `v_student_quiz_attempts` | `QuizSummary.attemptsCount` |
| `v_quiz_attempt_result` | `QuizResult` — contadores e `scorePercent` |
| `v_quiz_attempt_subject_performance` | `QuizResult.subjectPerformance` |
| `v_quiz_review_items` | `QuizResult.reviewItems` |
| `v_student_streak`, `v_student_ranking` | `streakDays`, `RankingData.entries` |
| `v_student_ranking_profile` | `RankingData.profile` |

---

## 3. Fora do MVP

Itens que existiam na primeira versão do modelo e foram removidos por não serem exigidos pelos
contratos atuais nem pelos critérios de aceite do MVP. Seguem a regra de
[`99-criterios-de-aceite-mvp.md`](99-criterios-de-aceite-mvp.md): *não implementar
funcionalidades complexas apenas porque foram mencionadas como possibilidades futuras*.

| Removido | Por quê | Quando volta |
|---|---|---|
| Subassunto (`subtopics`) | Os critérios de aceite pedem disciplinas, assuntos e materiais; o item 6 de [`05-melhorias-futuras.md`](05-melhorias-futuras.md) trata subassuntos como opcionais. Materiais passam a pertencer ao assunto. | Desempenho por subassunto ([`02-regras-de-negocio.md`](02-regras-de-negocio.md) §8) |
| Vínculo questão — material | "Encontrar questões relacionadas aos assuntos" é resolvido pelo assunto. | Recomendação "revisar o material correspondente" (§9) |
| Disciplina na questão (`questions.subject_id`) | Redundante com o assunto (ver normalização, seção 2.2). | — |
| Dificuldade por questão | Só o simulado tem dificuldade no contrato; desempenho por dificuldade não está nos critérios de aceite. | Fase 4 — Desempenho |
| Vínculo prova — simulado | `NextExam` não referencia simulado. | Modo Semana de Provas (Fase 5) |
| Limite de tentativas (`quizzes.attempts_allowed`) | Não existe limite: o aluno refaz o simulado quantas vezes quiser, e o contrato passa a informar quantas tentativas ele já enviou (`QuizSummary.attemptsCount`). | — |
| Contadores e nota gravados na tentativa | Derivados das respostas (seção 1.4). | — |
| Tabela `student_stats` | Contadores derivados; a meta semanal virou coluna de `students`. | Se o ranking ficar lento, depois de medir ([`03-arquitetura-tecnica.md`](03-arquitetura-tecnica.md)) |
| Início da tentativa (`started_at`) e horário de cada resposta | O contrato atual só cria a tentativa no envio, e o cronômetro fica no cliente no MVP. | Item 1 de [`05-melhorias-futuras.md`](05-melhorias-futuras.md) |
| Colunas de auditoria (`created_at`) | Nenhum contrato ou critério usa. Sessões e expiração de login ficam com o Supabase Auth. | Painel administrativo (Fase 7) |
| Tabela `auth_tokens` e coluna `students.password_hash` | O Supabase Auth guarda senhas e sessões. | — |

Continua fora do modelo, como já estava: o plano do dia (`todayPlan`), que hoje é só estado local
da UI ([`05-melhorias-futuras.md`](05-melhorias-futuras.md), item 4).
