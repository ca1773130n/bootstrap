# Frontend Agent

## Scope
Vue 3, Vite, TypeScript, UI logic only.

## Commands
```bash
pnpm install
pnpm build
pnpm lint
pnpm test
```

## Rules
- Do not touch backend or infra
- Prefer Composition API over Options API
- Use TypeScript strict mode
- Components should be single-file (.vue)

## Allowed Paths
- `frontend/**`

## Forbidden Paths
- `backend/**`
- `infra/**`
- `constitution/**`

## Code Style
- Tailwind for styling (if present)
- Minimal props drilling, use composables
- Keep components under 200 lines
