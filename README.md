# Bootstrap

Minimal Vue 3 + FastAPI starter. Transform into any webapp.

## Stack

- **Frontend**: Vue 3 + Vite + TypeScript
- **Backend**: FastAPI + Pydantic
- **Database**: PostgreSQL
- **CI**: GitHub Actions

## Quick Start

```bash
# Install dependencies
make install

# Option 1: Docker (recommended)
make up

# Option 2: Local dev
make dev-frontend  # Terminal 1
make dev-backend   # Terminal 2
```

## Structure

```
├── frontend/           # Vue 3 + Vite + TypeScript
├── backend/            # FastAPI + Pydantic
├── infra/              # Database schema
├── .github/workflows/  # CI pipeline
├── extras/             # Optional add-ons (see below)
├── docker-compose.yml  # Local development
└── Makefile            # Common commands
```

## Commands

```bash
make install     # Install dependencies
make up          # Start with Docker
make down        # Stop Docker
make dev         # Dev server instructions
make lint        # Run linters
make test        # Run tests
make build       # Production build
make all         # Lint + test + build
```

## Extras (Optional)

The `extras/` folder contains optional add-ons:

| Folder | Purpose |
|--------|---------|
| `extras/infra-fly/` | Fly.io deployment configs + VPS PostgreSQL guide |
| `extras/workflows/` | Additional GitHub Actions (deploy, auto-refactor) |
| `extras/agents/` | AI agent role definitions |
| `extras/constitution/` | AI agent governance rules |
| `extras/claude-skills/` | Claude Code skill modules |

To use any extra, copy files to their expected locations:

```bash
# Example: Enable Fly.io deployment
cp extras/infra-fly/fly.*.toml infra/
cp extras/workflows/deploy.yml .github/workflows/
```
