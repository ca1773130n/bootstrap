# Claude Code Instructions

Minimal project template for Vue 3 + FastAPI apps.

## Project Structure

- `frontend/` - Vue 3 + Vite + TypeScript
- `backend/` - FastAPI + Pydantic
- `infra/` - Database schema
- `extras/` - Optional add-ons (not part of core)

## Development

```bash
make up       # Docker dev environment
make lint     # Run linters
make test     # Run tests
```

## Code Style

- Frontend: TypeScript strict, Vue 3 Composition API
- Backend: Python 3.12+, type hints, Pydantic models
- Follow existing patterns in codebase

## Optional Extras

See `extras/` for optional add-ons:
- Fly.io deployment configs
- Additional CI workflows
- AI agent configurations
- Claude Code skills
