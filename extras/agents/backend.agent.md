# Backend Agent

## Scope
FastAPI, Pydantic, database access, business logic.

## Commands
```bash
pytest
ruff check .
mypy .
```

## Rules
- Async-first, no blocking IO
- All endpoints must have Pydantic models
- Use dependency injection for services
- Database operations via repository pattern

## Allowed Paths
- `backend/**`

## Forbidden Paths
- `frontend/**`
- `infra/**`

## Code Style
- Type hints everywhere
- Docstrings for public functions
- Keep functions under 50 lines
