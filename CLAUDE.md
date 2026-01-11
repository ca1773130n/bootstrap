# CLAUDE.md

Vue 3 + FastAPI bootstrap with adversarial testing patterns.

## Quick Start

```bash
make dev          # Start development servers
make test         # Run tests (100% coverage required)
make lint         # Lint all code
```

## Spec-Kit: Feature Planning System

Use these commands to plan and implement features properly.

| Command | Description |
|---------|-------------|
| `/specify` | Interview user to create detailed feature spec |
| `/plan` | Create implementation plan from spec |
| `/tasks` | Break plan into trackable todo items |

### /specify - Requirements Interview

**Triggers automatically when:**
- User says "I want to build/create/make X"
- User requests complex multi-system feature
- Scope is ambiguous or needs clarification
- User explicitly asks for planning/spec

**Protocol:** Conduct a structured interview using `AskUserQuestion` tool through 5 phases.

#### Phase 1: Context Gathering

Ask about:
- **Scope**: New feature, enhancement, or replacement?
- **Users**: Who uses this? (end users, admins, systems)
- **Timeline**: Any deadlines or dependencies?
- **Constraints**: Technical limitations, budget, team size?

```
AskUserQuestion with options like:
- Scope: "New feature" / "Enhancement" / "Replacement"
- Priority: "MVP (minimal)" / "Full feature" / "Exploratory"
```

#### Phase 2: Deep Dive

Ask about:
- **Edge cases**: What happens when X fails during Y?
- **Failure modes**: How should errors be handled?
- **Security**: Who should NOT access this?
- **Scale**: Expected load, data volume?

#### Phase 3: Technical

Ask about:
- **Data model**: What entities? Relationships?
- **API style**: REST or GraphQL? Sync or async?
- **State management**: Where does state live?
- **Error handling**: What errors are recoverable?

#### Phase 4: UI/UX (if applicable)

Ask about:
- **User journey**: Walk through the happy path
- **Error states**: What does user see on failure?
- **Loading states**: Skeleton, spinner, optimistic?
- **Mobile/Desktop**: Which is primary?

#### Phase 5: Priorities

Ask about:
- **MVP scope**: What's the minimum viable feature?
- **Cut list**: If time runs short, what goes first?
- **Build vs buy**: Any third-party options?

#### Output

Write spec to `docs/specs/{feature-name}-spec.md` using this template:

```markdown
# Feature: {Name}

## Overview
{2-3 sentence summary}

## Goals
- Primary: {main objective}
- Secondary: {nice-to-haves}

## Non-Goals
- {explicitly out of scope}

## User Stories
- As a {user}, I want {action} so that {benefit}

## Technical Design

### Data Model
{entities, relationships}

### API Endpoints
{routes, methods, payloads}

### UI Components (if applicable)
{component tree, states}

## Edge Cases & Error Handling
| Scenario | Behavior |
|----------|----------|
| ... | ... |

## Security Considerations
{auth, authz, data protection}

## Testing Strategy
{what to test, how}

## Open Questions
<!-- NEEDS_CLARIFICATION: {unresolved items} -->
```

### /plan - Implementation Planning

**Input:** Spec file path or feature name

**Process:**
1. Read spec from `docs/specs/`
2. If `NEEDS_CLARIFICATION` tags found, use `AskUserQuestion` to resolve
3. Design implementation:
   - Architecture decisions
   - Files to create/modify
   - Dependencies needed
   - Testing approach

**Output:** Implementation plan ready for execution

### /tasks - Task Breakdown

**Input:** Plan file or feature name

**Process:**
1. Parse plan into atomic tasks
2. Use `TodoWrite` tool to create structured list
3. Order by dependencies

### NEEDS_CLARIFICATION Tags

When you encounter ambiguity during implementation, mark with:

```markdown
<!-- NEEDS_CLARIFICATION: What should happen when X? -->
```

Then use `AskUserQuestion` to resolve before proceeding.

## Quality Gates

| Gate | Threshold | Command |
|------|-----------|---------|
| Test Coverage | 100% | `make test` |
| Mutation Score | 80% | `make test-mutation` |
| Lint | Zero errors | `make lint` |
| Type Check | Zero errors | `make lint` |

**Before every commit:**
1. Run `make lint` - fix all errors
2. Run `make test` - ensure 100% coverage
3. Then `git commit`

## Forbidden Actions

```bash
# NEVER USE - commits will be rejected
git commit --no-verify
git commit -n
git push origin main  # Always use feature branches
```

## Agent Roles & File Ownership

| Command | Domain | Allowed Paths | Commands |
|---------|--------|---------------|----------|
| `/backend` | FastAPI, Python | `backend/**` | `pytest`, `ruff`, `mypy` |
| `/frontend` | Vue 3, TypeScript | `frontend/**` | `pnpm test`, `pnpm lint` |
| `/testing` | Tests, Coverage | `**/test*/**` | `make test-adversarial` |
| `/infra` | Docker, Deploy | `infra/**` | `docker compose` |
| `/review` | Code Review | All (read-only) | - |
| `/simplify` | Pre-commit | Current changes | - |
| `/doc-sync` | Documentation | `**/*.md` | `make doc-sync` |

**Forbidden cross-modifications:**
- Backend agent cannot modify `frontend/**` or `infra/**`
- Frontend agent cannot modify `backend/**` or `infra/**`
- Never modify `extras/constitution/*` without human approval

## Adversarial Testing

This project uses Red Team / Blue Team patterns:

| Pattern | Code Writer | Test Writer |
|---------|-------------|-------------|
| A | Human | AI |
| B | AI | Human |
| C | AI (Blue) | AI (Red) |

**Property-based testing required:**
- Backend: Use Hypothesis
- Frontend: Use fast-check

**Mutation testing enforced:**
- 80% mutation score minimum
- Run with `make test-mutation`

## Commands Reference

```bash
# Development
make dev                 # Start dev servers
make up / make down      # Docker compose

# Testing
make test                # Full test suite (100% coverage)
make test-properties     # Property-based tests only
make test-mutation       # Mutation testing (80% threshold)
make test-adversarial    # All three: coverage + properties + mutation

# Feature workflow
make new-feature NAME=x  # Create isolated feature branch
make feature-up          # Start feature environment
make feature-down        # Stop feature environment

# Code generation
make openapi             # Regenerate TypeScript client
```

## Documentation Sync

Post-commit hook automatically syncs documentation. Triggers on:
- `backend/app/*.py` changes -> README.md
- `frontend/src/**` changes -> README.md
- `Makefile` changes -> README.md, AGENTS.md

Skip with: `DOC_SYNC_DISABLED=1 git commit -m "..."`

## Detailed Reference

For complete details on testing patterns, agent specifications, and governance rules:

@AGENTS.md
