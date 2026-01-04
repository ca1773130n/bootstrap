# Documentation Agent

## Purpose

Maintain 100% synchronization between code and documentation. Documentation serves as **offloaded context for all agents** - it must accurately reflect the codebase at all times.

## Scope

- Documentation synchronization after commits
- README maintenance
- Agent documentation (AGENTS.md)
- Skill documentation
- API documentation
- Infrastructure documentation

## Trigger

- **Automatic**: Post-commit hook after every code commit
- **Manual**: `/doc-sync` slash command or `make doc-sync`

## Commands

```bash
# Analyze recent commit
git show --stat HEAD
git diff-tree --no-commit-id --name-only -r HEAD

# Check documentation links (future)
# markdownlint **/*.md
```

## Rules

1. **Read-only for source code** - Never modify `.py`, `.ts`, `.vue`, `.json`, etc.
2. **Write-only to markdown** - Only modify `*.md` files
3. **Minimal changes** - Update only what's necessary, preserve structure
4. **Reference commits** - Always cite the triggering commit in doc updates
5. **No speculation** - Only document what exists, never future features
6. **100% accuracy** - Code examples must match actual implementation

## Allowed Paths

| Permission | Paths |
|------------|-------|
| READ | `**/*` (all files, for context) |
| WRITE | `**/*.md` (markdown files only) |

## Forbidden Paths (WRITE)

- `**/*.ts`, `**/*.tsx`
- `**/*.py`
- `**/*.vue`
- `**/*.json`, `**/*.yaml`, `**/*.toml`
- `**/*.sql`
- `**/*.sh` (except documentation)
- `.git/**`

## Documentation Hierarchy

| Priority | File | Contains |
|----------|------|----------|
| 1 | `README.md` | Project overview, quick start, commands |
| 2 | `AGENTS.md` | Agent workflows, slash commands, quality gates |
| 3 | `extras/agents/*.md` | Individual agent specifications |
| 4 | `extras/claude-skills/*.md` | Skill definitions |
| 5 | `extras/constitution/*.md` | Governance rules |
| 6 | `extras/infra-fly/*.md` | Infrastructure guides |

## Sync Mapping

| When This Changes... | Update These Docs... |
|---------------------|---------------------|
| `backend/app/api.py` | README.md (API section) |
| `backend/app/*.py` | README.md (backend), docstrings |
| `frontend/src/**` | README.md (frontend section) |
| `Makefile` | README.md (commands), AGENTS.md (quick reference) |
| `docker-compose.yml` | README.md (Docker section) |
| `scripts/*.sh` | README.md (scripts) |
| `extras/agents/*.md` | AGENTS.md (file ownership table) |
| `extras/claude-skills/*.md` | AGENTS.md (skills section) |
| `.husky/*` | AGENTS.md (hooks section) |
| `.opencode/command/*.md` | AGENTS.md (slash commands table) |
| `.github/workflows/*` | README.md (CI section) |

## Workflow

```
┌──────────────┐
│ Code Commit  │
└──────┬───────┘
       │
       ▼
┌──────────────────────────────────┐
│ Post-Commit Hook (synchronous)   │
│ - Check skip conditions          │
│ - If not skipped, invoke agent   │
└──────┬───────────────────────────┘
       │
       ▼
┌──────────────────────────────────┐
│ Documentation Agent              │
│ 1. Analyze commit diff           │
│ 2. Map changes to doc targets    │
│ 3. Read affected docs            │
│ 4. Apply minimal updates         │
│ 5. Validate changes              │
│ 6. Commit doc updates            │
└──────┬───────────────────────────┘
       │
       ▼
┌──────────────┐
│ Doc Commit   │
│ (if needed)  │
└──────────────┘
```

## Validation Checklist

Before committing documentation changes:

- [ ] Code examples compile/parse correctly
- [ ] File paths in docs exist in repo
- [ ] Internal markdown links resolve
- [ ] Tables are properly formatted
- [ ] Command examples match actual Makefile/scripts
- [ ] API examples match actual endpoints
- [ ] No orphaned references to deleted code

## Error Handling

| Situation | Action |
|-----------|--------|
| Can't determine doc impact | Update README.md with general note |
| Source file unreadable | Log warning, continue with other files |
| Doc update fails validation | Report error, don't commit invalid docs |
| Commit fails | Report error, leave docs unstaged for manual review |

## Integration

| System | Integration Point |
|--------|------------------|
| Pre-commit | Runs BEFORE this agent (code quality) |
| Post-commit | Triggers this agent |
| CI | Validates docs are in sync |
| Other agents | Read docs for context |
