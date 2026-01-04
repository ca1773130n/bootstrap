---
name: refactor_safe
version: 2.0.0
type: simplifier
description: Pre-commit code simplification with zero behavior change
scope:
  - code_quality
  - complexity_reduction
  - pre_commit_hook
allowed_paths:
  - frontend/src/**
  - backend/app/**
forbidden_paths:
  - "**/*.spec.*"
  - "**/*.test.*"
  - "**/*_test.py"
  - "**/test_*.py"
  - infra/**
  - constitution/**
requires:
  - tests_pass
  - coverage_unchanged
  - type_check_pass
  - no_signature_changes
commit_style: "refactor: simplify "
confidence_threshold: 0.9
rollback_on_failure: true
max_files_per_run: 10
run_before_commit: true
---

## Intent

Atomic code simplification before every commit. Reduce complexity without changing logic.
This is a **pre-commit gate** that ensures code stays clean and maintainable.

## Core Principle: Signature Preservation

**NEVER MODIFY:**
- Function signatures (parameters, return types)
- Class properties (names, types, visibility)
- Method signatures
- Exported symbol names
- API contracts

## Allowed Simplifications

### Safe Transformations (Always OK)

| Category | Example |
|----------|---------|
| Remove dead code | Unreachable branches, unused variables |
| Simplify conditionals | `if (x) return true; return false;` → `return x;` |
| Flatten nesting | Extract early returns to reduce indentation |
| Inline trivial variables | `const x = a; return x;` → `return a;` |
| Remove redundant else | After return/throw/continue |
| Simplify boolean logic | `!!x` → `Boolean(x)`, `x === true` → `x` |
| Consolidate duplicates | Extract repeated expressions to const |
| Remove empty blocks | Empty catch, finally, if blocks |
| Simplify string concat | Template literals where cleaner |
| Remove unnecessary async | When no await is used |

### Conditional Transformations (Verify First)

| Category | Condition |
|----------|-----------|
| Extract helper function | Only if internal (not exported) |
| Rename variable | Only if scope is local |
| Reorder statements | Only if no side-effect dependency |
| Combine declarations | Only same-type, related variables |

## Forbidden Actions

- Change function parameters (add, remove, reorder, rename)
- Change return types
- Change class property names or types
- Modify method visibility (public/private/protected)
- Change exported symbol names
- Modify error messages or codes
- Alter API responses
- Change database queries
- Modify event payloads

## Validation Protocol

### Before Simplification
```bash
# Snapshot current state
git stash --keep-index  # Preserve staged changes
make test               # Baseline test results
```

### After Each Simplification
```bash
# Verify no breakage
make test               # Must pass identically
make lint               # No new warnings
```

### Signature Check (Automated)
```typescript
// Frontend: Compare exports
// diff <(ast-grep exports before) <(ast-grep exports after)

// Backend: Compare signatures
// diff <(mypy stubgen before) <(mypy stubgen after)
```

## Execution Flow

```
┌─────────────────────────────────────────────┐
│           PRE-COMMIT SIMPLIFICATION         │
├─────────────────────────────────────────────┤
│ 1. Identify staged files                    │
│ 2. For each file:                           │
│    a. Analyze complexity hotspots           │
│    b. Apply ONE atomic simplification       │
│    c. Run tests on that file                │
│    d. If pass → keep, else → revert         │
│ 3. Report simplifications made              │
│ 4. Proceed with commit                      │
└─────────────────────────────────────────────┘
```

## Complexity Metrics to Reduce

| Metric | Target |
|--------|--------|
| Cyclomatic complexity | < 10 per function |
| Nesting depth | ≤ 3 levels |
| Function length | < 50 lines |
| Parameter count | ≤ 4 parameters |
| Boolean expressions | ≤ 3 conditions |

## Examples

### Before → After

```typescript
// BEFORE: Redundant else after return
function check(x: number): string {
  if (x > 0) {
    return "positive";
  } else {
    return "non-positive";
  }
}

// AFTER: Simplified
function check(x: number): string {
  if (x > 0) {
    return "positive";
  }
  return "non-positive";
}
```

```python
# BEFORE: Unnecessary variable
def get_name(user):
    name = user.name
    return name

# AFTER: Direct return
def get_name(user):
    return user.name
```

```typescript
// BEFORE: Complex boolean
const isValid = value !== null && value !== undefined && value !== "";

// AFTER: Simplified (if semantically equivalent)
const isValid = Boolean(value);
```

## Rollback Policy

If ANY test fails after simplification:
1. Immediately revert the change
2. Log the failed simplification attempt
3. Continue with next candidate
4. Never block the commit for simplification failures
