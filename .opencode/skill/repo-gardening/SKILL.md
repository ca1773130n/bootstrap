---
name: repo-gardening
description: Keep a clean, scalable repo structure without behavior changes
---

# Repo Gardening

Keep a clean, scalable Vue (Vite) + FastAPI repo structure without behavior changes.

## Canonical Structure

### Frontend (frontend/src)
```
frontend/src/
├── components/    # Pure UI components
├── pages/         # Route-level views
├── composables/   # Vue composables
└── api/           # API client code
```

### Backend (backend/app)
```
backend/app/
├── api/           # Route handlers
├── services/      # Business logic
├── models/        # Database models
└── schemas/       # Pydantic schemas
```

## Allowed Actions

- Move files to canonical folders
- Remove unused files/imports
- Enforce index re-exports
- Normalize naming (kebab-case FE, snake_case BE)

## Forbidden Actions

- Change runtime logic
- Modify public APIs
- Touch env, infra, CI

## Validation

- `git diff` must be structural-only
- FE build + BE tests unchanged

## Naming Conventions

| Layer | Convention | Example |
|-------|------------|---------|
| Frontend files | kebab-case | `user-profile.vue` |
| Frontend components | PascalCase | `UserProfile` |
| Backend files | snake_case | `user_service.py` |
| Backend classes | PascalCase | `UserService` |

## Index Re-exports

```typescript
// frontend/src/components/index.ts
export { default as Button } from './Button.vue'
export { default as Modal } from './Modal.vue'
```

```python
# backend/app/services/__init__.py
from .user_service import UserService
from .auth_service import AuthService
```

## Commit Message Format

```
chore(garden): <what was cleaned>

- Moved X to canonical location
- Removed unused Y
```
