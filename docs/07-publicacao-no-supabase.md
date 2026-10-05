# Publicação no Supabase pela CLI

Como levar as alterações do repositório para o projeto **hospedado** no Supabase: banco
(migrations), edge functions, CORS e o CAPTCHA do login. Para rodar o Supabase no seu computador,
veja [`PRIMEIROS-PASSOS.md`](PRIMEIROS-PASSOS.md#banco-de-dados-opcional); para o que cada parte faz,
[`06-modelagem-de-dados.md`](06-modelagem-de-dados.md) e
[`04-contratos-de-api.md`](04-contratos-de-api.md#edge-functions-e-cors).

## Sumário

1. [O que instalar](#1-o-que-instalar)
2. [Entrar e ligar o repositório ao projeto](#2-entrar-e-ligar-o-repositório-ao-projeto)
3. [Publicar edge functions](#3-publicar-edge-functions)
4. [Mudar o CORS](#4-mudar-o-cors)
5. [Ativar o CAPTCHA do login](#5-ativar-o-captcha-do-login)
6. [Publicar mudanças no banco](#6-publicar-mudanças-no-banco)
7. [Conferir e resolver problemas](#7-conferir-e-resolver-problemas)
8. [Resumo dos comandos](#8-resumo-dos-comandos)

## 1. O que instalar

| O quê | Para quê | Obrigatório? |
|---|---|---|
| [Node.js](https://nodejs.org/) 20.19+ ou 22.12+ | Roda o `npm` e o `npx`. | Sim |
| `npm install` na pasta do projeto | Instala a **CLI do Supabase**, que já é dependência de desenvolvimento do projeto (pacote `supabase`). Por isso todos os comandos começam com `npx supabase`. | Sim |
| Conta no [supabase.com](https://supabase.com/) com acesso ao projeto | Publicar no projeto hospedado. | Sim |
| Senha do banco do projeto | Pedida pelo `link` e pelo `db push`. Fica em **Project Settings → Database**; se ninguém souber, é possível redefini-la lá. | Sim |
| [Docker Desktop](https://www.docker.com/products/docker-desktop/) | Empacota as funções no deploy. Sem ele, use `--use-api` (o empacotamento é feito no servidor). | Não |

Não é preciso instalar a CLI globalmente nem o Deno: o `npx supabase` usa a versão fixada no
`package.json`, igual para todo o time. Confira com:

```bash
npx supabase --version
```

## 2. Entrar e ligar o repositório ao projeto

Feito **uma vez por computador**:

```bash
npx supabase login
```

Abre o navegador para autorizar a CLI na sua conta (ou pede um *access token*, gerado em
**Account → Access Tokens**).

Depois, ligue a pasta ao projeto hospedado. O **project ref** é o código que aparece na URL do
painel (`https://supabase.com/dashboard/project/<project-ref>`) e na URL da API
(`https://<project-ref>.supabase.co`):

```bash
npx supabase link --project-ref <project-ref>
```

A CLI pede a senha do banco e guarda a ligação em `supabase/.temp/` (fora do git). A partir daqui,
os comandos `deploy`, `secrets` e `db push` agem no projeto ligado.

## 3. Publicar edge functions

Cada endpoint é uma pasta em `supabase/functions/`; o código compartilhado fica em
`supabase/functions/_shared/`.

**Mudou só uma função** (por exemplo `supabase/functions/get-ranking/index.ts`):

```bash
npx supabase functions deploy get-ranking
```

**Mudou algo em `_shared/`** (como `http.ts`, `cors.ts` ou `db.ts`): o código compartilhado é
empacotado dentro de cada função, então **todas** precisam ser publicadas de novo. Sem nome, o
comando publica todas:

```bash
npx supabase functions deploy
```

Sem o Docker aberto, acrescente `--use-api`:

```bash
npx supabase functions deploy --use-api
```

Cuidados:

- **Função nova:** crie a pasta com `npx supabase functions new <nome>` e garanta que o
  `supabase/config.toml` tenha o bloco abaixo, como as outras já têm (se a CLI criar o bloco com
  `verify_jwt = true`, troque para `false`). O deploy lê o `verify_jwt` dali;
  se ele ficar ligado, o gateway recusa o preflight de CORS (que não leva token) e o app no
  navegador não consegue chamar a função.

  ```toml
  [functions.<nome>]
  verify_jwt = false
  ```

- **Função removida do repositório** continua no projeto até ser apagada:
  `npx supabase functions delete <nome>`.
- Antes de publicar, confira os tipos: `cd supabase/functions && npx deno check */index.ts`.
- As funções usam `SUPABASE_URL`, `SUPABASE_ANON_KEY` e `SUPABASE_DB_URL`, que o Supabase já
  fornece em todo projeto hospedado. O único secret que o projeto define é o `ALLOWED_ORIGINS`
  (próxima seção).

## 4. Mudar o CORS

O CORS de todas as funções é lido do secret `ALLOWED_ORIGINS` por `supabase/functions/_shared/cors.ts`:
uma lista de **origens** separadas por vírgula. Origem é protocolo + domínio + porta, **sem barra e
sem caminho no final** (`https://app.exemplo.com`, e não `https://app.exemplo.com/`). Uma origem que
não esteja na lista fica sem `Access-Control-Allow-Origin` e o navegador bloqueia a resposta; no app,
isso aparece como "Não foi possível conectar ao servidor".

Veja o que está configurado (a CLI mostra só um resumo do valor, não o texto):

```bash
npx supabase secrets list
```

Defina a lista:

```bash
npx supabase secrets set ALLOWED_ORIGINS=https://app.exemplo.com,http://localhost:5173
```

- O `set` **substitui** o valor inteiro: para acrescentar uma origem, repita todas as que já
  existiam.
- Não é preciso publicar as funções de novo: elas passam a usar o novo valor sozinhas.
- Mudar o código de `cors.ts` (por exemplo, aceitar outro header ou método) é mudança em
  `_shared/`: publique todas as funções, como na [seção 3](#3-publicar-edge-functions).
- Localmente, o valor vem de `supabase/functions/.env` (copiado de `.env.example`), e o gateway
  local libera qualquer origem; a restrição só aparece no projeto hospedado.

## 5. Ativar o CAPTCHA do login

O login usa o CAPTCHA do [Cloudflare Turnstile](https://developers.cloudflare.com/turnstile/),
validado pelo próprio Supabase Auth: não há edge function para isso. São duas chaves do widget
criado no painel da Cloudflare (**Turnstile → Widgets**):

- **site key**, pública: vai para o front, na variável `VITE_TURNSTILE_SITE_KEY`;
- **secret key**: fica só no Supabase. Nunca a coloque em `.env` do front, no repositório ou em chat.

Siga esta ordem, para o login não ficar fora do ar entre um passo e outro:

1. No widget da Cloudflare, cadastre os hostnames em que o app roda: o domínio da Vercel
   (`<projeto>.vercel.app`) e `localhost`, se o `npm run dev` apontar para o projeto hospedado.
   Cada preview da Vercel tem outro hostname e só mostra o widget se ele estiver cadastrado.
2. Na Vercel, defina `VITE_TURNSTILE_SITE_KEY` e publique o front. O widget aparece e o token já vai
   junto do login, mas ainda não é conferido.
3. No painel do Supabase, em **Authentication → Attack Protection**, ative o CAPTCHA, escolha
   **Turnstile** e cole a secret key. A partir daqui, um login sem token válido é recusado.

O CAPTCHA só protege depois do passo 3: sem ele, qualquer um chama o Supabase Auth direto, sem
token. No Supabase local o CAPTCHA fica desligado (`[auth.captcha]` comentado no `config.toml`);
deixe `VITE_TURNSTILE_SITE_KEY` vazia no `.env.development` para não mostrar o widget.

O widget é sempre renderizado no tema claro (`theme: "light"` em `TurnstileWidget`), porque o app
não tem tema escuro; sem isso ele seguiria o modo escuro do sistema.

Na tela de login, o console do navegador mostra avisos que vêm de dentro do iframe do Turnstile
(origem `…/normal?lang=pt-br`) e não do app: `Blocked script execution in 'about:blank'…`,
`The powerPreference option is currently ignored…`, `No available adapters.` e
`OTS parsing error: … WOFF 2.0…`. São esperados, não afetam o login e não dá para removê-los pelo
código do app. Para ver só os logs do app no DevTools, filtre com `-normal?lang`.

## 6. Publicar mudanças no banco

Toda mudança no banco é uma **migration nova**, nunca a edição de uma já aplicada:

```bash
npx supabase migration new <nome-da-mudanca>
```

Escreva o SQL no arquivo criado em `supabase/migrations/`, teste localmente com
`npx supabase db reset` e, quando estiver certo, veja o que falta aplicar no projeto hospedado e
aplique:

```bash
npx supabase migration list   # compara as migrations locais com as do projeto hospedado
npx supabase db push          # aplica as que faltam
```

O `db push` não roda o `supabase/seed.sql`: os dados de exemplo são só do ambiente local.

Se a mudança no banco for usada por uma edge function, publique o banco **antes** da função, para
ela nunca consultar uma coluna ou view que ainda não existe.

## 7. Conferir e resolver problemas

Depois de publicar, abra o app ligado ao projeto hospedado e navegue pelas telas. Os logs de cada
função ficam no painel, em **Edge Functions → <função> → Logs**.

| Sintoma | Causa provável |
|---|---|
| "Não foi possível conectar ao servidor", e o console do navegador fala em CORS | A origem do app não está no `ALLOWED_ORIGINS`, ou foi escrita com `/` no final. Veja a [seção 4](#4-mudar-o-cors). |
| Toda chamada responde `401` antes de chegar à função, inclusive o preflight | A função foi publicada com `verify_jwt` ligado: falta o bloco dela no `config.toml`. |
| "Ocorreu um erro inesperado" (`500`) | Erro dentro da função: veja os logs no painel. Se a mensagem citar coluna ou tabela inexistente, falta o `db push`. |
| "Não foi possível confirmar que você não é um robô" em todo login | O CAPTCHA está ativado no Supabase, mas o front foi publicado sem `VITE_TURNSTILE_SITE_KEY`, ou a secret key colada no Supabase não é a do mesmo widget. Veja a [seção 5](#5-ativar-o-captcha-do-login). |
| O widget do CAPTCHA mostra erro de domínio | O hostname do app não está cadastrado no widget da Cloudflare. |
| `Cannot find project ref. Have you run supabase link?` | Rode o `npx supabase link` da [seção 2](#2-entrar-e-ligar-o-repositório-ao-projeto). |
| O deploy reclama do Docker | Abra o Docker Desktop ou use `--use-api`. |

## 8. Resumo dos comandos

```bash
# uma vez por computador
npm install
npx supabase login
npx supabase link --project-ref <project-ref>

# banco (quando houver migration nova)
npx supabase db push

# edge functions
npx supabase functions deploy <nome>     # uma função
npx supabase functions deploy            # todas (obrigatório se mudou _shared/)

# CORS
npx supabase secrets set ALLOWED_ORIGINS=<origem1>,<origem2>
```
