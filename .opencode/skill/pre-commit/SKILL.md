---
name: pre-commit
description: Strict pre-commit quality gates - lint, type-check, and test before every commit
---

# Pre-Commit Quality Gates

This skill defines the MANDATORY quality gates that MUST pass before ANY commit.

## Gates (ALL REQUIRED)

| Gate | Command | Threshold |
|------|---------|-----------|
| 1. Lint staged files | `pnpm lint-staged` | Zero errors |
| 2. Type check (frontend) | `cd frontend && pnpm type-check` | Zero errors |
| 3. Type check (backend) | `cd backend && uv run mypy .` | Zero errors |
| 4. Tests (backend) | `cd backend && uv run pytest` | 100% coverage |
| 5. Tests (frontend) | `cd frontend && pnpm test:coverage` | 100% coverage |

## Automated Enforcement

The pre-commit hook (`.husky/pre-commit`) automatically runs all gates.
A backup hook exists in `.git/hooks/pre-commit`.

**Commits are BLOCKED if ANY gate fails.**

## Lint-Staged Configuration

Files are linted based on extension:

| Pattern | Linter |
|---------|--------|
| `frontend/**/*.{ts,tsx,vue,js,jsx}` | ESLint with --fix |
| `backend/**/*.py` | Ruff check + format |

## For AI Agents

Before committing, you MUST:

1. Run `make lint` and fix all errors
2. Run `make test` and ensure 100% coverage
3. Only then proceed with `git commit`

If you skip these steps, the pre-commit hook will block your commit.

## Bypassing (FORBIDDEN for AI Agents)

```bash
# NEVER USE THESE:
git commit --no-verify  # FORBIDDEN
git commit -n           # FORBIDDEN
```

AI agents are NEVER allowed to bypass pre-commit hooks.

## Troubleshooting

### Lint Errors
```bash
# Auto-fix frontend
cd frontend && pnpm lint

# Auto-fix backend
cd backend && uv run ruff check --fix .
cd backend && uv run ruff format .
```

### Type Errors
```bash
# Check frontend types
cd frontend && pnpm type-check

# Check backend types
cd backend && uv run mypy .
```

### Coverage < 100%
```bash
# See what's missing
cd backend && uv run pytest --cov-report=term-missing
cd frontend && pnpm test:coverage
```

Add tests for uncovered code before committing.
