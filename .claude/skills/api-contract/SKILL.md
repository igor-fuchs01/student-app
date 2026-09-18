---
name: api-contract
description: Add or change an API endpoint end to end in this project — endpoint path, zod schema, *Api module, MSW mock handler, Supabase function and adapter, UI query and docs/04-contratos-de-api.md — so no layer is left out of sync.
when_to_use: Whenever an endpoint, request body, response field or error of the backend contract is created, renamed, removed or changes shape (e.g. "add a field to QuizSummary", "create GET /materials", "the mock should return X").
---

# API contract change

The contract is shared by the future backend and the MSW mock, so a change is only done when every
layer below agrees. This is the expanded version of `docs/04-contratos-de-api.md` §6.

## 0. Classify the change before editing

Read `docs/04-contratos-de-api.md` §1.4:

- **Additive** (new endpoint, new optional response field): safe.
- **Breaking** (remove or rename a field, change its type, narrow allowed values): only when the
  user asked for it. Call it out explicitly in the final summary.

## 1. Path — `src/services/api/endpoints.ts`

- Add it to `API_ENDPOINTS`. Paths with ids are functions: `detail: (id: string) => \`/quizzes/${id}\``.
- Paths are relative to the base URL. Never include `/api`; `httpClient` adds it in mock mode.

## 2. Schema — `src/types/<feature>.ts` (imported as `@models/<feature>`)

- A zod schema for every request body and response, plus `export type X = z.infer<typeof xSchema>`.
- Mirror the documented rules: `.min(1)` for non-empty strings, `.int().nonnegative()` for counters,
  `.min(0).max(100)` for percentages, `z.enum([...])` for enums, `.optional()` only for documented
  optional fields.

## 3. API module — `src/services/api/<feature>Api.ts`

One method per endpoint, always passing the schema so the response is validated:

```ts
getRanking(signal?: AbortSignal): Promise<RankingData> {
  return httpClient.get(API_ENDPOINTS.ranking, rankingDataSchema, { signal });
},
```

GET methods accept `signal`. Components never call `httpClient` or `fetch` directly.

## 4. Mock — `src/services/api/mocks/`

- Add the route to `handlers.ts`, with the path wrapped in `api(...)`. Authenticated routes use
  `authenticated(...)`, which already answers 401 for a missing, tampered or expired JWT.
- Errors go through `errorResponse(status, code, message)`. `code` must exist in `API_ERROR_CODES`
  (`src/services/api/errors.ts`); `message` is friendly Portuguese, shown to the student as is.
- Validate request bodies with the same zod schema (`safeParse(await readJson(request))`) and answer
  400 `VALIDATION_ERROR` when it fails.
- Fixture data lives in the feature's mock file (`mocks/<feature>.ts`), with Portuguese content.
- Keep the catch-all 404 handler as the last entry of `handlers`.

## 5. Supabase — `supabase/migrations/` and `src/services/api/supabase/`

- Create a new migration (`npx supabase migration new <name>`); never edit one that was already
  applied. The function returns exactly the JSON shape of the contract DTO (camelCase keys, ids as
  text).
- Follow the access rules in `docs/06-modelagem-de-dados.md` ("Como o app acessa o banco"):
  `SECURITY DEFINER`, `set search_path = ''`, fully qualified names, the student only from
  `public.require_student_id()` (never from an argument), `revoke execute ... from public, anon` and
  `grant execute ... to authenticated`.
- Validate every value that comes from the client before using it; never build SQL from strings.
  Errors go through `public.raise_api_error(status, code, message)`.
- New tables get RLS enabled and, at most, SELECT policies; writes go through functions.
- In the adapter, call it with `callRpc("<function>", schema, { args, signal })` and select it in
  the `*Api` facade next to the mock implementation.

## 6. UI — `src/features/<feature>/`

- Reads use TanStack Query: `useQuery({ queryKey: [...], queryFn: ({ signal }) => xApi.getX(signal) })`.
  Put the user id in the key when the data is per student (see `RankingPage`, `DashboardPage`).
- Writes use `useMutation`. Never copy server data into Zustand or `useState`
  (`docs/03-arquitetura-tecnica.md`, "Gerenciamento de estado").

## 7. Docs — `docs/04-contratos-de-api.md` (Portuguese)

- §2 summary table: method, path, auth, success response, client method.
- The endpoint section: auth, request body table, a responses table with every status and error
  code, a JSON example, and "Comportamento no cliente" when the UI does something non-obvious.
- The §3.x model table for each new or changed DTO, with the same rules as the zod schema.
- §1.1: the endpoint → Supabase function table.
- §5 when the mock behaves differently from a real backend.
- When tables change, also update `docs/06-modelagem-de-dados.md` and `supabase/seed.sql`.

## 8. Verify

- `npm run build`, `npm run lint` and `npm run format:check`, checking each exit code.
- `Grep` the old field or path name across `src/`, `docs/` and `supabase/` and fix every leftover.
