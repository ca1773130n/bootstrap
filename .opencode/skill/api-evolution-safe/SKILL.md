---
name: api-evolution-safe
description: Evolve FastAPI APIs without breaking existing clients
---

# API Evolution Safe

Evolve FastAPI APIs without breaking existing clients.

## Rules

- Never modify existing route behavior
- Add new routes or versioned prefixes only (/v2)
- Pydantic schemas must be backward compatible
- Deprecate using OpenAPI metadata, not deletions

## Allowed Actions

- Add new endpoints
- Add optional fields with defaults
- Introduce new schema versions

## Forbidden Actions

- Remove fields or routes
- Change response semantics
- Tighten validation

## Validation

- OpenAPI diff must be additive-only
- Existing tests unchanged

## Example: Adding a Field

```python
# BEFORE
class UserResponse(BaseModel):
    id: int
    name: str

# AFTER (backward compatible)
class UserResponse(BaseModel):
    id: int
    name: str
    email: str | None = None  # Optional with default
```

## Example: Deprecating an Endpoint

```python
from fastapi import APIRouter, Depends
from typing import Annotated

router = APIRouter()

@router.get(
    "/users",
    deprecated=True,  # Mark in OpenAPI
    description="Use /v2/users instead"
)
async def get_users_v1():
    ...

@router.get("/v2/users")
async def get_users_v2():
    ...
```

## Scope

- `backend/app/api/**`
- `backend/app/schemas/**`
