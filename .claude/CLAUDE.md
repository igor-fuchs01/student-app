# Project Context

**Student App** — a web platform that helps students at a Brazilian institution
(ADS course) prepare for exams: study materials, practice questions, mock exams
(simulados), performance tracking, and study recommendations. Full product spec
lives in `docs/` (start at `docs/README.md`); do not duplicate that content here.

## Stack

- Vite + React 18 + TypeScript (strict) + styled-components.
- React Router v6 (`src/app/router.tsx`) with `ProtectedRoute` / `PublicOnlyRoute`
  guards driven by auth store status.
- TanStack Query for server-state (queries/mutations); Zustand only for real
  client-global state (e.g. `useAuthStore`).
- styled-components per component, using a shared theme (colors, radii, shadows)
  from `src/styles/theme.ts` via `ThemeProvider`, plus `src/styles/GlobalStyle.ts`
  for the base reset.

## Architecture

Full technical architecture lives in `docs/03-arquitetura-tecnica.md`; do not
duplicate that content here.

## Styling convention

- Every styled-components primitive is prefixed with `Styled` (e.g. `StyledBrand`) this distinguishes a
  styled-components export from a plain React component at a glance.
- Each component lives in its own `ComponentName/` folder:
  - `ComponentName.tsx` (the exported React component, plain name, no `Styled` prefix) 
  - `ComponentName.styles.ts` (its `Styled*` primitives)
  -  `index.ts` (re-exports only the component, not the `Styled*` primitives).
- `Styled*` primitives are private to their component file never import one
from outside its own `ComponentName.styles.ts`/`ComponentName.tsx` pair.
- Exception: `GlobalStyle` (from `createGlobalStyle`, in `src/styles/GlobalStyle.ts`)
  keeps its conventional name, it is a singleton mounted once in `App.tsx`, not a
  component instantiated like the others.

## Language convention

- Code, identifiers, comments, commit messages: **English**.
- UI copy (labels, buttons, messages shown to the student) and mock/fixture
  *content* (subject names, plan items, student names, etc.): **Portuguese**,
  since the product is for Portuguese-speaking students.

---

# Rules

* Do not use other language, always english to the code, component's name, etc, and portuguese to mockup data and UI.
* Follow existing project patterns before introducing new ones.
* Reuse existing services, components, utilities and abstractions whenever possible.
* Prefer modifying existing code over creating new files.
* Keep changes as small as possible.
* Document modifications according the docs, if needed.
* Do not refactor unrelated code.
* Do not introduce new dependencies without clear justification.
* Do not create abstractions for a single use case.
* Do not leave TODO comments.
* Do not leave commented code.

---

# File Creation Policy

Before creating a new file:

1. Search for an existing implementation.
2. Search for a similar component.
3. Verify that extending existing code is not possible.

Create new files only when there is no reasonable alternative.

---

# API Rules

* Never break existing public contracts.
* Maintain backward compatibility.
* Reuse existing DTO patterns.
* Follow existing validation conventions.

---

# Testing Rules

When modifying code:

* Update existing tests if necessary.
* Add tests for new behavior.
* Ensure all tests pass before considering the task complete.

---

# Documentation Rules

* Do not create documentation files outside /docs.
* Never forget to update the documentation, when necessary.
* If no relevant documentation exists, create it.
* Keep documentation synchronized with the current implementation.
* Documentation is considered part of the deliverable.

---

# Code Review Checklist

Before finishing any task verify:

* Project builds successfully.
* Tests pass.
* Lint passes.
* No unused imports.
* No dead code.
* No commented code.
* No debugging statements.
* No duplicated logic introduced.
* Folders are separated by feature.

After finishing any task execute:

* Run `git diff --staged` and `git diff` to see all changes
* Group changes by logical responsibility (new functionality, bug fix, refactoring,
  configs/deps/build, documentation)
* Use `git add -p` or `git add <file>` for selective staging
* Make one commit per group
* Every commit message starts with `feat: ` — no other type (`fix`, `chore`, `docs`,
  `refactor`…) and no scope in parentheses, whatever the kind of change.
  Example: `feat: stop sending answers left blank`
* Always prefer small commits: split each group into the smallest meaningful units
  (one component, one fix, one config change, one doc topic), and make sure every
  commit builds and passes lint on its own
* Never mix unrelated changes (for example a new feature and a bug fix) in the same commit
* Never add Co-Authored-By lines to commit messages
* Never push without prior authorization

---

# Forbidden Actions

* Never rewrite large sections of code without request.
* Never rename files solely for preference.
* Never change architecture without request.
* Never introduce new frameworks.
* Never modify environment configuration without request.
* Never modify CI/CD pipelines without request.
* Never push commits to the repository, even if the user requests it.

---

# Definition of Done

A task is complete only if:

* Build succeeds.
* Lint passes.
* Changes are minimal.
* Existing behavior is preserved.
* New functionality works as requested.
* You ask for if you can commit the changes. 