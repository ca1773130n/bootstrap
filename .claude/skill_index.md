# Skill Index

## Available Skills

| Skill | Type | Purpose |
|-------|------|---------|
| `smart_commit` | workflow | Auto-group changes, atomic commits, spawn doc/test agents |
| `repo_gardening` | maintenance | Repository hygiene, file organization |
| `doc_sync` | documentation | Keep docs in sync with code |
| `refactor_safe` | refactor | Safe internal refactoring |
| `ci_fix` | automation | Auto-fix CI failures |
| `api_evolution_safe` | evolution | Evolve FastAPI APIs without breaking clients |
| `vue_perf_tune` | performance | Vue 3 + Vite performance optimization |

## Skill Details

### smart_commit
- **Trigger**: Before committing, when multiple files changed
- **Scope**: All uncommitted changes
- **Safety**: High (analyzes before acting)
- **Spawns**: document-writer, test verification agents

### repo_gardening
- **Trigger**: Scheduled or manual
- **Scope**: File structure, naming, dead code
- **Safety**: High (structural only)

### doc_sync  
- **Trigger**: Post-merge or manual
- **Scope**: All markdown documentation
- **Safety**: High (docs only)

### refactor_safe
- **Trigger**: Manual with coverage gate
- **Scope**: Internal code quality
- **Safety**: Medium (requires 80% coverage)

### ci_fix
- **Trigger**: CI failure detected
- **Scope**: Workflow steps, versions, caching
- **Safety**: High (minimal fixes only)

### api_evolution_safe
- **Trigger**: OpenAPI diff detected
- **Scope**: FastAPI routes, Pydantic schemas
- **Safety**: High (additive-only changes)

### vue_perf_tune
- **Trigger**: Bundle size regression detected
- **Scope**: Vue components, reactivity, code splitting
- **Safety**: High (no UX changes)

## Rules

1. **Explicit invocation only** - Never auto-select skills
2. **One skill per run** - Unless explicitly chained
3. **Respect constraints** - Skill metadata is binding
4. **Report blocked actions** - Transparency on what couldn't be done

## Chaining Skills

Skills can be chained when explicitly requested:
```
Apply repo_gardening then doc_sync to the repository.
```

Execution order matters - earlier skills may affect later ones.

## Adding New Skills

1. Create `.claude/skills/<name>.skill.md`
2. Include required YAML frontmatter
3. Add to this index
4. Test with dry-run first
