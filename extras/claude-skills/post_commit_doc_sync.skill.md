---
name: post_commit_doc_sync
version: 1.0.0
type: workflow
description: Synchronously sync documentation after every code commit
scope:
  - documentation
  - git
  - post-commit
  - context-engineering
allowed_paths:
  - "**/*.md"
forbidden_paths:
  - "**/*.ts"
  - "**/*.py"
  - "**/*.vue"
  - "**/*.json"
  - "**/*.yaml"
  - "**/*.toml"
  - .git/**
requires:
  - recent_commit
commit_style: "docs: sync documentation for "
confidence_threshold: 0.7
spawns:
  - document-writer
execution_mode: synchronous
skip_if_commit_prefix:
  - "docs(sync):"
  - "docs: sync documentation"
---

## Intent

Ensure documentation is **always 100% synchronized** with code after every commit. Documentation is the offloaded context for all agents - keeping it in sync is critical for effective context engineering.

**This skill runs synchronously and blocks until complete.**

## Why Synchronous?

1. **Context Consistency**: Agents may read docs immediately after a commit
2. **No Race Conditions**: Multiple rapid commits won't create conflicting doc syncs
3. **Guaranteed Order**: Code commit -> Doc sync commit -> Next code commit
4. **Audit Trail**: Every code change has a corresponding doc change (if needed)

## Trigger Conditions

### Auto-Trigger (post-commit hook)
- Runs **synchronously** after every successful `git commit`
- Blocks until documentation sync is complete
- Skips only if commit message starts with `docs(sync):` or `docs: sync documentation`

### Manual Trigger
- `/doc-sync` slash command
- `make doc-sync`

## Skip Conditions

The skill skips **only** when:
1. Commit message starts with `docs(sync):` (prevents infinite loops)
2. Commit message starts with `docs: sync documentation` (same)

**Note**: Unlike other skills, this does NOT skip for markdown-only commits. Even doc changes might need cross-references updated.

## Workflow

### Phase 1: Commit Analysis

```bash
#!/bin/bash
set -e

COMMIT_SHA=$(git rev-parse HEAD)
COMMIT_MSG=$(git log -1 --format='%s' HEAD)
COMMIT_SHORT=$(git rev-parse --short HEAD)

echo "Analyzing commit: $COMMIT_SHORT - $COMMIT_MSG"

# Check for skip condition (infinite loop prevention)
case "$COMMIT_MSG" in
  docs\(sync\):*|"docs: sync documentation"*)
    echo "SKIP: Doc sync commit detected"
    exit 0
    ;;
esac

# Get changed files
CHANGED_FILES=$(git diff-tree --no-commit-id --name-only -r HEAD)
echo "Changed files:"
echo "$CHANGED_FILES" | sed 's/^/  /'
```

### Phase 2: Impact Mapping

Determine which documentation files need updates based on changed source files:

```
IMPACT_MAP:
  backend/app/api.py        -> README.md, AGENTS.md
  backend/app/*.py          -> README.md
  backend/pyproject.toml    -> README.md
  backend/tests/*           -> (no doc update needed)
  frontend/src/**/*.ts      -> README.md
  frontend/src/**/*.vue     -> README.md
  frontend/package.json     -> README.md
  Makefile                  -> README.md, AGENTS.md
  docker-compose.yml        -> README.md
  scripts/*.sh              -> README.md
  extras/agents/*.md        -> AGENTS.md
  extras/claude-skills/*.md -> AGENTS.md
  extras/constitution/*.md  -> AGENTS.md
  .husky/*                  -> AGENTS.md
  .opencode/command/*.md    -> AGENTS.md
  infra/*                   -> README.md, extras/infra-fly/*.md
  .github/workflows/*       -> README.md
```

### Phase 3: Documentation Update

Spawn Documentation Agent (document-writer) with full context:

```
CONTEXT:
  Commit SHA: ${COMMIT_SHA}
  Commit Message: ${COMMIT_MSG}
  Changed Files: ${CHANGED_FILES}

TASK:
  Synchronize all documentation to reflect the changes in this commit.
  
PROCESS:
  1. For each changed file, read and understand the modification
  2. Identify all documentation that references this file or its functionality
  3. Update documentation to accurately reflect the new state
  4. Ensure code examples match actual implementation
  5. Update tables, lists, and cross-references
  6. Validate all changes before committing

CRITICAL:
  - Documentation is agent context - accuracy is paramount
  - Every public API change MUST be documented
  - Every command change MUST be reflected in README/AGENTS.md
  - No source code modifications allowed
```

### Phase 4: Commit Documentation

```bash
# Check for documentation changes
if git diff --quiet -- '*.md'; then
  echo "Documentation already in sync - no changes needed"
  exit 0
fi

# Show what will be committed
echo "Documentation changes:"
git diff --stat -- '*.md'

# Stage and commit
git add '*.md'
git commit -m "docs: sync documentation for ${COMMIT_MSG}"

NEW_SHA=$(git rev-parse --short HEAD)
echo "Documentation synced: $NEW_SHA"
```

## Commit Message Format

```
docs: sync documentation for <original-commit-message>
```

Examples:
- `docs: sync documentation for feat(api): add user profile endpoint`
- `docs: sync documentation for fix(db): handle connection timeout`
- `docs: sync documentation for refactor: extract validation logic`

## Validation

Before committing documentation changes, verify:

| Check | How |
|-------|-----|
| Code examples valid | Parse/syntax check |
| File paths exist | `test -f <path>` |
| Links resolve | Check `[text](path)` targets |
| Tables formatted | Markdown lint |
| No placeholders | Grep for TODO/FIXME/XXX |

## Error Recovery

| Error | Recovery |
|-------|----------|
| Agent fails to identify changes | Default to updating README.md |
| Documentation update invalid | Reject update, report to user |
| Commit fails | Leave changes staged, report error |
| Pre-commit hook fails on doc commit | Fix issues, retry commit |

## Metrics

Track for quality monitoring:
- Time to sync (should be < 60s for most commits)
- Docs updated per commit (average)
- Sync failures (should be 0)
- Manual interventions required

## Integration Points

| Hook | Relationship |
|------|-------------|
| pre-commit | Runs BEFORE code commit (validates code) |
| **post-commit** | Runs AFTER code commit (this skill) |
| pre-push | Could validate docs are in sync |
| CI | Final validation that docs match code |
