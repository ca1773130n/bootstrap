---
name: ci-fix
description: Fix CI failures without masking real issues
---

# CI Fix

Fix CI failures without masking real issues.

## Allowed Actions

- Fix test flakiness
- Adjust workflow steps
- Add missing install/cache steps
- Align node/python versions

## Forbidden Actions

- Disable tests
- Weaken assertions
- Skip checks
- Change infra deploy logic

## Validation

- CI must pass green
- Root cause explained in commit body

## Common Fixes

### Test Flakiness

```yaml
# Add retry for flaky tests
- name: Run tests
  run: |
    for i in 1 2 3; do
      make test && break
      echo "Retry $i..."
      sleep 5
    done
```

### Missing Dependencies

```yaml
# Ensure dependencies are cached
- uses: actions/cache@v4
  with:
    path: ~/.cache/pip
    key: ${{ runner.os }}-pip-${{ hashFiles('**/requirements.txt') }}
```

### Version Alignment

```yaml
# Pin versions explicitly
- uses: actions/setup-python@v5
  with:
    python-version: '3.12'
```

## Debugging Steps

1. Check CI logs for first error
2. Reproduce locally if possible
3. Identify root cause (not just symptom)
4. Apply minimal fix
5. Document in commit message

## Commit Message Format

```
ci(fix): <what was fixed>

Root cause: <explanation>
Fix: <what was changed>
```
