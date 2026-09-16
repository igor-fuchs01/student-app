# Arquitetura Técnica

## Stack obrigatória

- **React**
- **TypeScript** (strict)

## Estrutura de pastas

Organização por *feature*, não por tipo de arquivo. Estrutura atual:

```text
src/
├── app/
│   ├── providers/     # QueryProvider (TanStack Query)
│   ├── routes/        # ProtectedRoute, PublicOnlyRoute, RouteErrorPage
│   └── router.tsx     # definição das rotas (data router)
├── components/
│   ├── layout/        # AppHeader, PageLayout (header + conteúdo da página)
│   └── ui/            # componentes base, sem regra de negócio (Badge, Button, Card, Modal, ...)
├── features/
│   ├── auth/          # login, store de sessão (Zustand), useLogout
│   ├── dashboard/
│   ├── quizzes/       # lista, tentativa, revisão e resultado de simulados
│   ├── ranking/
│   └── subjects/
├── services/
│   ├── api/           # httpClient, módulos *Api, endpoints, erros e mocks/
│   └── storage/       # tokenStorage e quizAttemptStorage (localStorage)
├── styles/            # theme e GlobalStyle
├── types/             # schemas zod e tipos inferidos (alias @models)
├── utils/             # utilitários genéricos, sem regra de negócio
├── App.tsx
└── main.tsx
```

Features planejadas, criadas em `features/` conforme forem implementadas: `materials`, `study`,
`questions`, `attempts`, `performance`, `recommendations`, `gamification` e `profile`.

Dentro de uma feature, cada componente fica em sua própria pasta (`Componente.tsx`,
`Componente.styles.ts` e `index.ts`), hooks ficam em `hooks/` e funções puras da feature ficam
na raiz da feature (ex.: `features/quizzes/isQuestionAnswered.ts`).

Imports entre pastas usam os aliases `@app`, `@components`, `@features`, `@services`, `@styles`,
`@models` (para `src/types`) e `@utils`.

### Por que assim

O risco natural deste produto é que **toda a lógica acabe concentrada na feature de simulados**. As features de `performance`, `recommendations` e `gamification` são partes centrais do produto e precisam existir como domínios próprios, com suas próprias regras, não como abas dentro do simulado.

`questions/` (o motor de renderização e resposta de questões) deve ser independente de `quizzes/` e `attempts/` — uma questão pode ser praticada fora de um simulado. Hoje esse motor (`QuestionField`) ainda vive em `features/quizzes/` e deve ser extraído para `features/questions/` quando surgir a prática de questões fora de simulados.

---

## Roteamento

- As rotas ficam em `src/app/router.tsx`, com `createBrowserRouter`.
- `ProtectedRoute` e `PublicOnlyRoute` são rotas de layout: decidem, pelo `status` da store de
  autenticação, se renderizam as rotas filhas (`<Outlet />`) ou redirecionam.
- Cada página é carregada sob demanda (`lazy`), gerando um chunk por rota.
- Erros de renderização ou de carregamento de uma rota exibem `RouteErrorPage`.

---

## Gerenciamento de estado

Duas ferramentas, com fronteiras claras.

### TanStack Query — dados do servidor

Responsável por tudo que vem da API:

- fetching de dados;
- cache;
- estados de loading;
- mutations;
- sincronização / revalidação.

### Zustand — estado global do cliente

Usado **somente quando houver necessidade real** de estado global que não venha do servidor.

### A regra que evita a maior dor de cabeça

> **Não duplicar dados da API em estados globais.**

Se o dado veio do servidor, ele vive no cache do TanStack Query. Copiá-lo para uma store Zustand cria duas fontes de verdade e bugs de sincronização difíceis de rastrear.

---

## Camada de serviços

`services/` é isolado da UI:

- `services/api/` — clientes HTTP e DTOs;
- `services/api/mocks/` — servidor mock feito com [MSW](https://mswjs.io/) (Mock Service Worker):
  `handlers.ts` responde às rotas da API e `mockServer.ts` registra o Service Worker
  (`public/mockServiceWorker.js`) quando `VITE_USE_MOCKS=true`. O `httpClient` não sabe que existe
  mock: ele faz `fetch` normalmente, e o MSW intercepta as chamadas sob o prefixo `/api`;
- `services/storage/` — localStorage para sessão (`tokenStorage`) e resultados de tentativas
  (`quizAttemptStorage`, com chave por aluno). IndexedDB pode ser adotado quando a persistência
  durante a tentativa for implementada.

Refresh de token ainda não existe; quando existir, deve ficar em `services/`.

Componentes não fazem chamadas HTTP diretamente. A separação entre apresentação e lógica é obrigatória.

---

## Persistência local

A persistência de respostas durante o simulado é a parte mais sensível do sistema (ver `regras-de-negocio.md`, seção 4).

Estratégia:

1. Resposta é registrada localmente (IndexedDB ou equivalente) imediatamente;
2. Sincronização com o backend acontece de forma progressiva;
3. A UI indica claramente respostas ainda não sincronizadas;
4. Ao reabrir uma tentativa, o estado local é reconciliado com o servidor;
5. Envios devem ser idempotentes para evitar duplicação de respostas.

> Estado atual: as respostas ficam só em memória até o envio. Essa limitação foi aceita para o
> MVP; a proposta de implementação está em [`05-melhorias-futuras.md`](05-melhorias-futuras.md), item 1.

---

## Performance

Considerar e aplicar quando fizer diferença real:

- lazy loading;
- code splitting (por rota e por feature);
- paginação;
- virtualização de listas longas;
- cache;
- carregamento progressivo;
- otimização de imagens;
- evitar renders desnecessários.

Não otimizar sem medir. Otimização prematura é complexidade sem retorno.

---

## Trade-offs assumidos no MVP

| Decisão | Trade-off aceito |
|---------|------------------|
| Correção manual de dissertativas | Menos automação, mas evita rubricas mal definidas e correção errada |
| Curadoria manual das questões | Escala menor, mas garante confiabilidade do conteúdo |
| Mocks de API iniciais | Frontend avança sem backend pronto, desde que os contratos sejam mantidos |
| Timer validado no backend | Mais complexidade, mas impede manipulação pelo cliente |
| Persistência local + sincronização | Mais código, mas elimina o pior cenário do produto (perda de respostas) |

---

## Regra de arquitetura

> **Não criar abstrações desnecessárias.**

Priorizar código simples, legível e fácil de manter. Uma abstração se justifica quando já existe repetição real, não quando ela *pode* existir no futuro.
