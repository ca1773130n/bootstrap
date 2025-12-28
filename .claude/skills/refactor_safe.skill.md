---
name: refactor_safe
version: 1.0.0
type: refactor
description: Internal refactoring with guaranteed zero behavior change
scope:
  - code_quality
  - internal_structure
allowed_paths:
  - frontend/src/**
  - backend/app/**
forbidden_paths:
  - "**/*.test.*"
  - "**/*_test.py"
  - infra/**
  - constitution/**
requires:
  - tests_pass
  - coverage_minimum: 80
  - type_check_pass
commit_style: "refactor(safe): "
confidence_threshold: 0.85
rollback_on_failure: true
max_files_per_run: 5
---

## Intent

Perform internal refactoring that improves code quality without changing observable behavior.
Every refactor must be provably safe through existing tests.

## Allowed Actions

- Extract functions/methods from large blocks
- Rename internal (non-exported) symbols
- Simplify conditional logic
- Remove dead code paths (proven unreachable)
- Consolidate duplicate code into shared utilities
- Improve type definitions (narrowing, not widening)
- Convert callbacks to async/await (internal only)

## Forbidden Actions

- Change public API signatures
- Modify exported function names
- Alter return types of public functions
- Change error messages (may break client parsing)
- Modify database queries
- Change HTTP status codes
- Alter event names or payload shapes

## Validation Criteria

- All existing tests pass without modification
- No new test failures
- Type checking passes
- Coverage does not decrease
- Public API surface unchanged (verified via exports diff)

## Safety Checks

1. **Before**: Snapshot all exported symbols
2. **After**: Compare exports, fail if changed
3. **Before**: Record test results
4. **After**: Tests must produce identical results

## Execution Pattern

1. Identify refactoring candidates (complexity, duplication)
2. Verify test coverage for affected code
3. Apply single refactoring transformation
4. Run full test suite
5. Verify exports unchanged
6. Commit atomically
7. Repeat for next candidate (up to max_files_per_run)
