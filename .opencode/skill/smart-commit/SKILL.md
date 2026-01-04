---
name: smart-commit
description: Intelligently group and commit changes with auto-generated docs and tests
---

# Smart Commit

Analyze all uncommitted changes, group them by logical units, create atomic commits with proper conventional commit messages, and automatically trigger documentation and test updates.

## Workflow

### Phase 1: Analysis

1. Run `git status` and `git diff` to collect all changes
2. Analyze session history for modification patterns
3. Categorize changes by:
   - `feat`: New functionality
   - `fix`: Bug fixes
   - `refactor`: Code restructuring
   - `docs`: Documentation only
   - `test`: Test additions/changes
   - `chore`: Config, deps, tooling
   - `style`: Formatting, no logic change

### Phase 2: Grouping Strategy

Group files into logical commit units based on:

1. **Dependency Graph**: Files that import/reference each other
2. **Directory Proximity**: Related paths (e.g., `api.py` + `test_api.py`)
3. **Change Type**: Separate features from fixes from refactors
4. **Session History**: What was modified together in sequence

Grouping Rules:
- One feature = one commit
- One bug fix = one commit
- Related test files commit WITH their implementation
- Doc updates can bundle OR spawn doc-sync agent
- Config changes separate from code changes

### Phase 3: Commit Execution

For each logical group:

```bash
1. Stage files: git add <files>
2. Generate commit message:
   - type(scope): short description
   - blank line
   - bullet points of changes (if complex)
3. Commit: git commit -m "message"
4. Verify: git status
```

### Phase 4: Auto-Documentation

After code commits, spawn document-writer agent if needed.

### Phase 5: Auto-Testing

After code commits, verify tests pass and coverage maintained.

## Commit Message Format

```
<type>(<scope>): <short description>

[optional body with bullet points]

[optional footer: Closes #issue, Breaking Change, etc.]
```

## Example

### Input: Mixed changes
```
modified: backend/app/api.py (new endpoint)
modified: backend/app/models.py (new model)
modified: backend/tests/test_api.py (new tests)
modified: frontend/src/api.ts (new API call)
modified: README.md (updated docs)
modified: pyproject.toml (new dep)
```

### Output: 3 commits
```
1. feat(api): add user profile endpoint
   - backend/app/api.py
   - backend/app/models.py
   - backend/tests/test_api.py

2. feat(frontend): add profile API integration
   - frontend/src/api.ts

3. chore(deps): add pydantic-settings
   - pyproject.toml
```

## Validation

Before each commit:
- [ ] Files in group are logically related
- [ ] Commit message follows conventional format
- [ ] No unrelated changes bundled
- [ ] Tests still pass (if test files exist)

After all commits:
- [ ] `git log` shows clean history
- [ ] Each commit is atomic and revertable

## Forbidden Actions

- Commit unrelated changes together
- Use generic messages ("fix stuff", "updates")
- Skip test files that belong with implementation
- Force push without explicit permission
- Commit secrets or credentials
- Suppress pre-commit hooks
