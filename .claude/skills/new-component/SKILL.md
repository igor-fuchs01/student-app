---
name: new-component
description: Create a React component with this project's styled-components folder convention — ComponentName/ with .tsx, .styles.ts and index.ts, Styled* primitives kept private, theme tokens for styling.
when_to_use: Whenever a new component is added under src/components or src/features/*/components (e.g. "create a card for materials", "extract this block into a component").
---

# New component

## 1. Reuse first

Search before creating (`Glob src/**/components/**`). If an existing component fits with a new prop,
extend it: CLAUDE.md prefers modifying existing code over new files.

## 2. Pick the folder

| Kind of component | Folder |
|---|---|
| Generic UI with no business rules, reusable anywhere (Badge, Button, Modal…) | `src/components/ui/` |
| Page skeleton (header, page layout) | `src/components/layout/` |
| Anything that knows about a feature (quizzes, ranking…) | `src/features/<feature>/components/` |

## 3. Create the three files

```text
ComponentName/
├── ComponentName.tsx        the exported React component (plain name)
├── ComponentName.styles.ts  its Styled* primitives
└── index.ts                 re-exports the component only
```

Reference implementation: `src/components/ui/Badge/`.

### `ComponentName.styles.ts`

- Every styled export is prefixed with `Styled` (`StyledBadge`).
- Colors, radii and shadows come from the theme (`src/styles/theme.ts`):
  `${({ theme }) => theme.colors.accent600}`. No hard-coded palette colors.
- Props used only for styling are transient (`$tone`), so they never reach the DOM.
- Types shared with the component (such as a `BadgeTone` union) may be declared here.

### `ComponentName.tsx`

```tsx
import type { HTMLAttributes } from "react";
import { StyledBadge, type BadgeTone } from "./Badge.styles";

type BadgeProps = HTMLAttributes<HTMLSpanElement> & {
  tone?: BadgeTone;
};

export function Badge({ tone = "neutral", ...rest }: BadgeProps) {
  return <StyledBadge $tone={tone} {...rest} />;
}
```

- Named function export; props typed as `ComponentNameProps`.
- Import `Styled*` only from its own `./ComponentName.styles`, never from another component.
- UI copy in Portuguese, identifiers in English, no explanatory comments.
- No `fetch` or `httpClient`. Server data comes from TanStack Query in the page component.

### `index.ts`

```ts
export { Badge } from "./Badge";
export type { BadgeTone } from "./Badge.styles";
```

Re-export public types when consumers need them, never `Styled*` primitives.

## 4. Use it

Import through the alias and the folder, not the file: `import { Badge } from "@components/ui/Badge";`.

## 5. Verify

`npm run build`, `npm run lint` and `npm run format:check`, checking each exit code.
