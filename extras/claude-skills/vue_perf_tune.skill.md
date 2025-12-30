---
name: vue_perf_tune
version: 1.0.0
type: performance
scope:
  - frontend/src/**
allowed_paths:
  - frontend/**
forbidden_paths:
  - backend/**
  - infra/**
requires:
  - bundle_size_regression
commit_style: perf(vue)
confidence_threshold: 0.85
---

## Intent

Improve Vue 3 + Vite performance without UX changes.

## Allowed actions

- Code splitting (dynamic import)
- Refactor reactive hot paths
- Memoization (computed, shallowRef)
- Remove dead components

## Forbidden actions

- UI redesign
- API contract changes
- Feature removal

## Validation

- Bundle size reduced
- Lighthouse score unchanged or better
