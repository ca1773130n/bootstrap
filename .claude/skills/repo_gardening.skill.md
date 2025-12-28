---
name: repo_gardening
version: 1.1.0
type: maintenance
scope:
  - filesystem
  - imports
  - structure
allowed_paths:
  - frontend/**
  - backend/**
forbidden_paths:
  - infra/**
  - .github/**
requires:
  - tests_pass
commit_style: chore(garden)
confidence_threshold: 0.85
---

## Intent

Keep a clean, scalable Vue (Vite) + FastAPI repo structure without behavior changes.

## Canonical structure

frontend/src:
  - components/ (pure UI)
  - pages/ (route-level)
  - composables/
  - api/

backend/app:
  - api/
  - services/
  - models/
  - schemas/

## Allowed actions

- Move files to canonical folders
- Remove unused files/imports
- Enforce index re-exports
- Normalize naming (kebab-case FE, snake_case BE)

## Forbidden actions

- Change runtime logic
- Modify public APIs
- Touch env, infra, CI

## Validation

- `git diff` must be structural-only
- FE build + BE tests unchanged
