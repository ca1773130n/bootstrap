---
description: Synchronize all documentation with code changes from a commit
argument-hint: "[commit-ref]"
agent: document-writer
---

# Documentation Sync

Synchronize all documentation files with code changes. Documentation is the offloaded context for all agents - it must be 100% in sync with code at all times.

## Commit Reference
{{ argument | default: "HEAD" }}

## Task

You are the Documentation Agent. Your job is to ensure all documentation accurately reflects the current codebase state after commit `{{ argument | default: "HEAD" }}`.

### Step 1: Analyze the Commit

Run these commands to understand what changed:

```bash
# Get commit details
git log -1 --format='%H %s' {{ argument | default: "HEAD" }}

# Get changed files
git diff-tree --no-commit-id --name-only -r {{ argument | default: "HEAD" }}

# Get the actual diff
git show {{ argument | default: "HEAD" }}
```

### Step 2: Check Skip Conditions

**SKIP ENTIRELY** if the commit message starts with:
- `docs(sync):`
- `docs: sync documentation`

If skipped, output: "Skipping: doc sync commit detected" and exit.

### Step 3: Map Changes to Documentation

For EACH changed file, determine documentation impact:

| Source File Pattern | Documentation to Update |
|--------------------|------------------------|
| `backend/app/api.py` | README.md (API endpoints), AGENTS.md (if commands change) |
| `backend/app/*.py` | README.md (backend section) |
| `backend/pyproject.toml` | README.md (dependencies, commands) |
| `frontend/src/**/*.ts` | README.md (frontend section) |
| `frontend/src/**/*.vue` | README.md (components) |
| `frontend/package.json` | README.md (dependencies, scripts) |
| `Makefile` | README.md (commands table), AGENTS.md (quick reference) |
| `docker-compose.yml` | README.md (Docker section) |
| `scripts/*.sh` | README.md (scripts section) |
| `extras/agents/*.md` | AGENTS.md (file ownership, agent table) |
| `extras/claude-skills/*.md` | AGENTS.md (skills reference) |
| `extras/constitution/*.md` | AGENTS.md (rules summary) |
| `.husky/*` | AGENTS.md (pre-commit section) |
| `.opencode/command/*.md` | AGENTS.md (slash commands table) |
| `infra/*` | README.md, extras/infra-fly/*.md |
| `.github/workflows/*` | README.md (CI section) |

### Step 4: Read and Update Documentation

For each documentation file that needs updates:

1. **Read** the current documentation file
2. **Read** the changed source files to understand the new behavior
3. **Identify** specific sections that need updates
4. **Apply** minimal, accurate changes:
   - Update code examples to match actual code
   - Update tables/lists with new entries
   - Update command references
   - Fix any references to renamed/moved files
   - Add documentation for new public APIs
   - Remove documentation for deleted features
5. **Preserve** existing structure, formatting, and style

### Step 5: Validate Changes

Before committing, verify:
- [ ] All code examples are syntactically valid
- [ ] All file path references exist
- [ ] All internal links resolve
- [ ] Tables are properly formatted
- [ ] No TODO/FIXME placeholders (unless intentional)
- [ ] Changes are minimal and accurate

### Step 6: Commit Documentation Updates

```bash
# Check if there are any markdown changes
git status --porcelain -- '*.md'

# If changes exist, stage and commit
git add '*.md'
git commit -m "docs: sync documentation for $(git log -1 --format='%s' {{ argument | default: 'HEAD' }})"
```

If no documentation changes are needed, output: "Documentation is already in sync."

## Allowed Paths (WRITE)
- `**/*.md`

## Forbidden Actions
- **NEVER** modify source code (`.py`, `.ts`, `.vue`, `.json`, `.yaml`, `.toml`)
- **NEVER** modify test files
- **NEVER** delete documentation without explicit instruction
- **NEVER** add speculative documentation for unimplemented features
- **NEVER** skip documentation updates silently

## Output

Return a summary:
```
Documentation Sync Complete
===========================
Commit: <sha> <message>
Files analyzed: <count>
Documentation updated:
  - README.md: <what changed>
  - AGENTS.md: <what changed>
  - ...
Doc commit: <new-sha> (or "No changes needed")
```
