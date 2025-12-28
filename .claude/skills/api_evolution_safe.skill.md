---
name: api_evolution_safe
version: 1.0.0
type: evolution
scope:
  - backend/app/api/**
  - backend/app/schemas/**
allowed_paths:
  - backend/**
forbidden_paths:
  - frontend/**
  - infra/**
requires:
  - openapi_diff_detected
  - tests_pass
commit_style: feat(api)
confidence_threshold: 0.9
---

## Intent

Evolve FastAPI APIs without breaking existing clients.

## Rules

- Never modify existing route behavior.
- Add new routes or versioned prefixes only (/v2).
- Pydantic schemas must be backward compatible.
- Deprecate using OpenAPI metadata, not deletions.

## Allowed actions

- Add new endpoints
- Add optional fields with defaults
- Introduce new schema versions

## Forbidden actions

- Remove fields or routes
- Change response semantics
- Tighten validation

## Validation

- OpenAPI diff must be additive-only
- Existing tests unchanged
