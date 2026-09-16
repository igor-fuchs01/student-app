---
name: finish-task
description: Run this project's definition of done before wrapping up a task — build, lint and format checks, diff review, leftover and docs checks — then propose small "feat:" commits and ask before committing.
when_to_use: Triggered by the user with /finish-task, or messages like "finish the task", "verify everything and commit".
disable-model-invocation: true
---

# Finish task

Follow the steps in order. When a step fails, fix it and restart from step 1.

## 1. Checks

```bash
npm run build
npm run lint
npm run format:check
```

Report the real exit code of each one. Piping into `tail` or `head` hides it, so run them one by one.

## 2. Review the diff

- `git status`, `git diff` and `git diff --staged`.
- Nothing unrelated to the task, no debugging statements, commented-out code, TODOs or unused imports.
- Files the user staged or edited themselves are theirs: never commit, unstage or revert them
  without asking.

## 3. Leftovers and docs

- For every renamed or removed name (field, path, file, component), `Grep` the old name across
  `src/`, `docs/`, `database/` and `README.md`.
- Docs in `docs/` are Portuguese and must match the code:
  - contract → `04-contratos-de-api.md`;
  - architecture, folders, state → `03-arquitetura-tecnica.md`;
  - persisted data → `06-modelagem-de-dados.md` and `database/`;
  - accepted limitations → `05-melhorias-futuras.md`;
  - setup or commands → `PRIMEIROS-PASSOS.md`, `CONTRIBUTING.md`, `README.md`.

## 4. Propose commits, then ask

- Group by responsibility and split into the smallest meaningful units (one component, one fix,
  one config change, one doc topic). Never mix unrelated changes.
- Each commit must build and pass lint on its own.
- Subject: `feat: <imperative summary in English>`, with no scope and no other type, whatever the
  change. The body explains why. Never add `Co-Authored-By`. The hook
  `.claude/hooks/validate-commit-message.mjs` blocks anything else.
- Show the proposed list and **ask before committing** (CLAUDE.md, Definition of Done).
- Commit only the listed paths (`git commit -m "..." -- <paths>`), so files the user staged stay out.
- Never push.
