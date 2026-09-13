# Arquitetura Técnica

## Stack obrigatória

- **React**
- **TypeScript** (strict)

## Estrutura de pastas

Organização por *feature*, não por tipo de arquivo:

```text
src/
├── app/
│   ├── router/
│   ├── providers/
│   └── config/
├── assets/
├── components/
│   ├── ui/            # componentes base, sem regra de negócio
│   └── shared/        # componentes compostos reutilizáveis
├── features/
│   ├── auth/
│   ├── dashboard/
│   ├── subjects/
│   ├── materials/
│   ├── study/
│   ├── questions/
│   ├── quizzes/
│   ├── attempts/
│   ├── performance/
│   ├── recommendations/
│   ├── gamification/
│   └── profile/
├── hooks/
├── layouts/
├── pages/
├── services/
│   ├── api/
│   ├── auth/
│   └── storage/
├── store/
├── types/
├── utils/
└── App.tsx
```

### Por que assim

O risco natural deste produto é que **toda a lógica acabe concentrada na feature de simulados**. As features de `performance`, `recommendations` e `gamification` são partes centrais do produto e precisam existir como domínios próprios, com suas próprias regras, não como abas dentro do simulado.

`questions/` (o motor de renderização e resposta de questões) deve ser independente de `quizzes/` e `attempts/` — uma questão pode ser praticada fora de um simulado.

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
- `services/auth/` — sessão, tokens, refresh;
- `services/storage/` — IndexedDB / localStorage para persistência de tentativas.

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
