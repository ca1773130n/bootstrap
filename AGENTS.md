# AGENTS.md

AI-agent friendly development guide for this Vue 3 + FastAPI project.

## Overview

This project uses **adversarial testing patterns** to ensure AI-generated code meets production quality standards. Humans and AI agents work in complementary roles: one writes code, the other writes tests.

Key principles:
- 100% test coverage enforced at CI
- Mutation testing validates test strength
- Property-based tests discover edge cases
- Ephemeral environments isolate feature work

## Human-AI Workflow Patterns

### Red Team / Blue Team Testing

| Role | Writes Code | Writes Tests |
|------|-------------|--------------|
| **Pattern A** | Human | AI Agent |
| **Pattern B** | AI Agent | Human |
| **Pattern C** | AI Agent (Blue) | AI Agent (Red) |

The adversarial relationship ensures neither party can game the metrics.

### Property-Based Testing Contracts

Human defines invariants. AI generates test cases.

**Backend (Hypothesis):**
```python
from hypothesis import given, strategies as st

@given(origins=st.lists(st.text(), max_size=10))
def test_cors_parsing_never_crashes(self, origins: list[str]) -> None:
    # Invariant: parsing any input never raises
    result = parse_cors_origins(",".join(origins))
    assert isinstance(result, list)
```

**Frontend (fast-check):**
```typescript
import { test, fc } from "@fast-check/vitest";

test.prop([fc.webUrl()])("any URL is parseable", (url) => {
  expect(() => new URL(url)).not.toThrow();
});
```

### Interview-Driven Spec Generation (Future)

```
Human: "Implement user authentication"
    ↓
AI (Spec Agent): Generates formal requirements
    ↓
AI (Blue Team): Implements code
    ↓
AI (Red Team): Writes adversarial tests
    ↓
Human: Reviews and approves
```

## Test Quality Gates

| Metric | Backend | Frontend | Enforced At |
|--------|---------|----------|-------------|
| Line Coverage | 100% | 100% | CI |
| Branch Coverage | 100% | 100% | CI |
| Mutation Score | ≥80% | ≥80% | CI |
| Property Tests | Required | Required | CI |

Thresholds configured in:
- Backend: `backend/pyproject.toml` (`--cov-fail-under=100`)
- Frontend: `frontend/stryker.config.json` (`"break": 80`)

## Quick Reference

```bash
# Standard testing
make test                    # Run all tests with coverage
make test-properties         # Property-based tests only

# Mutation testing
make test-mutation           # Run mutation tests (80% threshold)

# Full adversarial suite (coverage → properties → mutation)
make test-adversarial

# Feature development
make new-feature NAME=foo    # Create isolated branch + ports
make feature-up              # Start feature environment
make feature-down            # Stop feature environment
make feature-clean           # Remove feature environment

# Code generation
make openapi                 # Regenerate TypeScript client from OpenAPI
```

### Ephemeral Feature Environments

`new-feature.sh` creates isolated development environments:

```bash
make new-feature NAME=user-auth
# Creates:
#   - Branch: feature/user-auth
#   - Database port: 5532 (deterministic from name)
#   - Backend port: 8100
#   - Frontend port: 5273
#   - Schema: feature_user_auth
```

Each feature gets unique ports derived from feature name hash. No collisions.

## Adversarial Patterns

### When AI Writes Code, Human/Red-Team AI Writes Tests

```
┌─────────────────┐     ┌─────────────────┐
│   Blue Team     │     │   Red Team      │
│   (Code AI)     │────▶│   (Test AI)     │
│                 │     │                 │
│ Implements      │     │ Tries to break  │
│ feature         │     │ implementation  │
└─────────────────┘     └─────────────────┘
         │                       │
         ▼                       ▼
┌─────────────────────────────────────────┐
│            Mutation Testing             │
│   Validates test suite catches bugs     │
└─────────────────────────────────────────┘
```

### Property Tests: Human Defines Invariants, AI Generates Cases

```python
# Human writes the invariant
def test_balance_never_negative(self, transactions):
    """INVARIANT: Account balance can never go below zero"""
    account = process_transactions(transactions)
    assert account.balance >= 0

# AI/Hypothesis generates thousands of transaction sequences
@given(transactions=st.lists(st.builds(Transaction, ...)))
```

### Mutation Testing: Validates Test Strength

Mutation testing inserts bugs and checks if tests catch them.

**Backend (mutmut):**
```bash
cd backend && ./scripts/mutation-test.sh
# Threshold: 80% of mutations must be killed
```

**Frontend (Stryker):**
```bash
cd frontend && pnpm test:mutation
# Threshold: 80% (configured in stryker.config.json)
```

If mutation score drops below 80%, CI fails.

## File Ownership

| Agent | Owns | Commands |
|-------|------|----------|
| **Backend** | `backend/**` | `pytest`, `ruff check`, `mypy` |
| **Frontend** | `frontend/**` | `pnpm test`, `pnpm lint`, `pnpm build` |
| **Infra** | `infra/**`, `extras/infra-fly/**` | `fly deploy`, `docker compose` |
| **Reviewer** | All files (read-only) | Reviews PRs against checklist |

### Forbidden Paths

| Agent | Cannot Modify |
|-------|---------------|
| Backend | `frontend/**`, `infra/**` |
| Frontend | `backend/**`, `infra/**` |
| Infra | `backend/**`, `frontend/**` |

### Cross-Cutting Concerns

| File | Requires |
|------|----------|
| `docker-compose.yml` | Infra + affected agent |
| `Makefile` | Owner of related command |
| `.github/workflows/*` | Human approval |
| `extras/constitution/*` | Human approval only |

## Agent Rules Summary

1. **Never push to main** - All changes via feature branches
2. **Run tests before commit** - `make test` must pass
3. **Preserve public APIs** - Unless explicitly told to break them
4. **Ask when uncertain** - Confidence < 70% = stop and report
5. **Document reasoning** - Commit messages explain "why"

See `extras/constitution/agent_rules.md` for full governance rules.
