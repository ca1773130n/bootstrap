---
name: ci_fix
version: 1.0.0
type: automation
scope:
  - ci
allowed_paths:
  - .github/workflows/**
  - frontend/**
  - backend/**
requires:
  - failing_ci
commit_style: ci(fix)
rollback_on_failure: true
confidence_threshold: 0.9
---

## Intent

Fix CI failures without masking real issues.

## Allowed actions

- Fix test flakiness
- Adjust workflow steps
- Add missing install/cache steps
- Align node/python versions

## Forbidden actions

- Disable tests
- Weaken assertions
- Skip checks
- Change infra deploy logic

## Validation

- CI must pass green
- Root cause explained in commit body
