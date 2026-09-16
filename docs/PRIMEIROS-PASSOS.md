# Primeiros passos

Guia para quem acabou de rodar o projeto e quer entender o que está acontecendo. Para instalar e
ligar o app, veja o [`README`](../README.md).

## Sumário

1. [As telas](#as-telas)
2. [O que é o "mock"?](#o-que-é-o-mock)
3. [Como o login funciona](#como-o-login-funciona)
4. [Comandos úteis](#comandos-úteis)
5. [Como o projeto está organizado](#como-o-projeto-está-organizado)
6. [Tecnologias](#tecnologias)
7. [Banco de dados (opcional)](#banco-de-dados-opcional)
8. [Deu erro?](#deu-erro)
9. [Glossário](#glossário)

## As telas

| Tela | O que você encontra |
|---|---|
| 🔐 **Login** | Entrada com matrícula ou e-mail. Não existe cadastro: as contas são criadas pelo responsável. |
| 🏠 **Início** | A próxima prova, os assuntos que merecem mais atenção e um plano de estudo do dia. |
| 📘 **Disciplinas** | As matérias do curso, com quantidade de materiais, questões e o seu nível de preparo. |
| 📝 **Simulados** | Provas de treino com cronômetro (ou sem limite), 6 tipos de questão, marcação para revisar depois e revisão antes de enviar. |
| 📊 **Resultado** | Acertos, erros, desempenho por disciplina e a explicação de cada questão errada. |
| 🔥 **Ranking** | Quem estudou mais dias seguidos. **Nunca** mostra nota de ninguém. |

Os 6 tipos de questão:

| Tipo | Como funciona |
|---|---|
| Múltipla escolha | Uma alternativa correta. |
| Múltiplas alternativas | Mais de uma alternativa correta. |
| Seleção única | Você completa um texto escolhendo opções em listas. |
| Arrastar e soltar | Você arrasta termos para os espaços certos do texto. |
| Dissertativa | Você escreve a resposta. |
| Dissertativa com lacunas | Você completa um texto digitando nas lacunas. |

A conta de teste aceita a matrícula `senaiigorpereira` ou o e-mail `igor@email.com`, com a senha
`123456`.

## O que é o "mock"?

Um sistema como este normalmente tem duas partes:

- **Frontend**: a parte que você vê e clica (telas, botões). É o que existe neste repositório.
- **Backend**: um servidor que guarda os dados de verdade (alunos, questões, notas) e responde ao
  frontend.

O backend **ainda não existe**. Para o frontend funcionar mesmo assim, o comando `npm run mock` liga
um **servidor de mentira** que roda dentro do próprio navegador e responde com dados de exemplo.
"Mock" quer dizer justamente isso: uma imitação. Você usa o app normalmente, mas nada é salvo de
verdade: recarregou a página, algumas informações (como o número de tentativas) voltam ao início.

Quem faz essa imitação é a biblioteca **MSW** (Mock Service Worker). Ela fica "no meio do caminho"
entre o app e a internet: quando o app pede algo para a API, o MSW intercepta o pedido e responde
no lugar do backend. Quer ver acontecendo? Com o app aberto, aperte <kbd>F12</kbd>, vá na aba
**Rede** (*Network*) e navegue pelas telas: os pedidos que começam com `/api` são respondidos pelo
mock.

As respostas ficam em [`handlers.ts`](../src/services/api/mocks/handlers.ts), os dados de exemplo na
mesma pasta [`src/services/api/mocks/`](../src/services/api/mocks/), e a conta de teste em
[`users.ts`](../src/services/api/mocks/users.ts).

## Como o login funciona

Quando você entra, o servidor (o mock, por enquanto) te entrega um **token JWT**. Pense nele como um
**crachá digital**: em cada tela que precisa de login, o app mostra esse crachá ao servidor para
provar que é você.

Esse crachá **vence em 3 dias**. Depois disso, o servidor não aceita mais, e você volta
automaticamente para a tela de login para pegar um novo.

Os detalhes técnicos estão em [`04-contratos-de-api.md`](04-contratos-de-api.md), seção 5.

## Comandos úteis

Todos rodam no terminal, dentro da pasta do projeto:

| Comando | O que faz | Quando usar |
|---|---|---|
| `npm run mock` | Liga o app com dados de exemplo. | **No dia a dia.** É o jeito mais fácil de ver o app funcionando. |
| `npm run dev` | Liga o app conectado a um backend de verdade. | Só quando existir um backend (veja [Deu erro?](#deu-erro)). |
| `npm run build` | Gera a versão final e otimizada do site, na pasta `dist`. | Para conferir se está tudo compilando. |
| `npm run lint` | Procura erros e más práticas no código (ESLint). | Antes de enviar uma alteração. |
| `npm run format` | Arruma a formatação do código automaticamente (Prettier). | Antes de enviar uma alteração. |
| `npm run format:check` | Só verifica a formatação, sem mudar nada. | É o que a CI usa. |

Para desligar o app, volte ao terminal e aperte <kbd>Ctrl</kbd> + <kbd>C</kbd>.

## Como o projeto está organizado

```text
student-app/
├── src/                  → 💻 o código do app
│   ├── app/              →    rotas (qual tela abre em qual endereço)
│   ├── components/       →    peças visuais reutilizáveis (botões, cards, modais…)
│   ├── features/         →    cada funcionalidade em sua pasta
│   │   ├── auth/         →       login e logout
│   │   ├── dashboard/    →       tela de Início
│   │   ├── subjects/     →       Disciplinas
│   │   ├── quizzes/      →       Simulados e resultado
│   │   └── ranking/      →       Ranking
│   ├── services/         →    conversa com o servidor (API) e com o navegador (localStorage)
│   ├── styles/           →    cores, fontes e estilos gerais
│   └── types/            →    o "formato" dos dados que vêm da API
├── database/             → 🐘 scripts do banco de dados e Docker
└── docs/                 → 📖 documentação completa do produto
```

> 💡 **Dica para quem está começando:** comece lendo uma tela de ponta a ponta. Por exemplo, abra
> `src/features/ranking/` e siga o caminho: a tela → o `rankingApi` em `services/api/` → o formato
> dos dados em `types/ranking.ts` → os dados de exemplo em `services/api/mocks/ranking.ts`.

## Tecnologias

| Tecnologia | Para que serve aqui, em uma frase |
|---|---|
| **React** | Monta as telas em pedaços reutilizáveis, chamados componentes. |
| **TypeScript** | É o JavaScript com tipos: avisa de muitos erros antes mesmo de rodar o código. |
| **Vite** | Liga o projeto em modo de desenvolvimento e gera a versão final do site. |
| **styled-components** | Permite escrever o CSS de cada componente junto dele. |
| **React Router** | Decide qual tela aparece para cada endereço (`/simulados`, `/ranking`…). |
| **TanStack Query** | Busca os dados do servidor e guarda em cache para não pedir de novo à toa. |
| **Zustand** | Guarda informações que o app inteiro precisa, como "quem está logado". |
| **Zod** | Confere se os dados que chegaram do servidor têm o formato esperado. |
| **MSW** | Imita o backend dentro do navegador, para o app funcionar com dados de exemplo. |
| **PostgreSQL + Docker** | O banco de dados planejado para o backend, e um jeito fácil de ligá-lo no seu computador. |

## Banco de dados (opcional)

> **Você não precisa disto para rodar o app.** O `npm run mock` já basta. Esta parte é para quem
> quer mexer com o banco de dados que o backend utiliza.

O banco foi modelado a partir do que o app precisa. A explicação completa, com diagramas, está em
[`06-modelagem-de-dados.md`](06-modelagem-de-dados.md), e os scripts ficam em
[`database/`](../database/).

O **Docker** roda programas dentro de "caixinhas" isoladas, chamadas **containers**. Assim você usa
um PostgreSQL sem precisar instalá-lo e configurá-lo à mão. Com o
[Docker](https://www.docker.com/products/docker-desktop/) instalado, um comando liga o banco já com
as tabelas criadas e dados de exemplo:

```bash
docker compose -f database/docker-compose.yml up -d
```

Para se conectar com um programa como o [DBeaver](https://dbeaver.io/) ou o
[pgAdmin](https://www.pgadmin.org/), use:

| Campo | Valor |
|---|---|
| Host | `localhost` |
| Porta | `5432` |
| Banco | `student_app` |
| Usuário | `student_app` |
| Senha | `student_app` |

- Para desligar: `docker compose -f database/docker-compose.yml down`.
- Para desligar **e apagar os dados**: `docker compose -f database/docker-compose.yml down -v`.

## Deu erro?

### ❌ "npm" ou "node" não é reconhecido como comando

O Node.js não está instalado, ou o terminal foi aberto antes da instalação. Instale pelo
[nodejs.org](https://nodejs.org/), **feche e abra o terminal de novo** e tente outra vez.

### ❌ Rodei `npm run dev` e a página ficou em branco

O `npm run dev` tenta falar com um backend de verdade, e ele ainda não existe. Use
**`npm run mock`**. Se você tiver um backend, copie o arquivo de exemplo de configuração e coloque
nele o endereço da sua API:

```bash
cp .env.development.example .env.development
```

### ❌ "Port 5173 is already in use"

Já tem outro projeto usando essa porta, provavelmente o próprio Student App aberto em outro
terminal. Feche o outro terminal (ou aperte <kbd>Ctrl</kbd> + <kbd>C</kbd> nele) e rode de novo.

### ❌ Erro na instalação ou versão do Node muito antiga

Confira a versão com `node -v`. O projeto precisa da **20.19+** ou da **22.12+**. Se a sua for mais
antiga, instale a versão LTS do [nodejs.org](https://nodejs.org/), apague a pasta `node_modules` e
rode `npm install` de novo.

### ❌ Fui mandado de volta para a tela de login

É normal: o seu "crachá" (token) venceu, depois de 3 dias. Basta entrar de novo com a conta de
teste.

## Glossário

| Palavra | Em português claro |
|---|---|
| **Clonar** | Baixar uma cópia do repositório para o seu computador. |
| **Dependência** | Uma biblioteca feita por outras pessoas que o projeto usa. |
| **API** | O "cardápio" de pedidos que o frontend pode fazer ao backend. |
| **Mock** | Uma imitação: aqui, um servidor falso com dados de exemplo. |
| **Token / JWT** | Um crachá digital que prova quem você é depois do login. |
| **Build** | A versão final e otimizada do site, pronta para publicar. |
| **Lint** | Uma revisão automática do código atrás de erros comuns. |
| **CI** | Um robô que testa o código sempre que alguém envia mudanças. |
| **MVP** | A primeira versão do produto, só com o essencial. |
| **Docker / container** | Uma caixinha isolada que roda um programa já configurado. |
| **localhost** | O endereço do seu próprio computador. |
