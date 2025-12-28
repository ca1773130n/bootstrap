# Bootstrap

Agent-first, constitution-driven project template for Vue 3 + FastAPI.

## Stack

- **Frontend**: Vue 3 + Vite + TypeScript
- **Backend**: FastAPI + Pydantic
- **Database**: PostgreSQL (self-hosted on VPS)
- **Hosting**: Fly.io
- **CI/CD**: GitHub Actions

## Quick Start

```bash
make install
make dev
```

## Structure

```
├── constitution/       # Agent governance rules
├── agents/             # Agent role definitions
├── .claude/
│   ├── skills/         # Claude Code skill modules
│   ├── instructions.md
│   └── skill_index.md
├── .github/workflows/  # CI/CD automation
├── frontend/           # Vue 3 + Vite
├── backend/            # FastAPI
├── infra/              # Fly.io, PostgreSQL configs
└── scripts/            # Setup & deployment scripts
```

## Deployment

### Option 1: Automated Setup (Recommended)

```bash
# 1. Copy and edit config
cp .env.fly.example .env.fly
nano .env.fly

# 2. Run setup (creates apps, sets secrets, deploys)
./scripts/fly-setup.sh
```

### Option 2: Manual Setup

```bash
# Install CLI
brew install flyctl
fly auth login

# Create apps
fly apps create myapp-api
fly apps create myapp-web

# Set secrets
fly secrets set DATABASE_URL="postgresql://..." -a myapp-api

# Deploy
fly deploy --config infra/fly.backend.toml --app myapp-api
fly deploy --config infra/fly.frontend.toml --app myapp-web
```

### Update Secrets Anytime

```bash
# Edit .env.fly, then:
./scripts/fly-secrets.sh
```

### CI/CD Auto-Deploy

1. Get deploy token:
   ```bash
   fly tokens create deploy -x 999999h
   ```

2. Add to GitHub:
   - Go to repo → Settings → Secrets → Actions
   - Add `FLY_API_TOKEN`

3. (Optional) Add variables for custom app names:
   - `FLY_APP_API` (default: myapp-api)
   - `FLY_APP_WEB` (default: myapp-web)

Every push to `main` auto-deploys. You'll get:
- Preview URLs in workflow summary
- Mobile notification via GitHub app

### Database Setup

See [infra/postgres-vps.md](infra/postgres-vps.md) for VPS PostgreSQL setup.

## Claude Code Skills

| Skill | Purpose |
|-------|---------|
| `repo_gardening` | File organization, dead code removal |
| `doc_sync` | Keep docs in sync with code |
| `refactor_safe` | Safe internal refactoring (80% coverage required) |
| `ci_fix` | Auto-fix CI failures |
| `api_evolution_safe` | Backward-compatible API changes |
| `vue_perf_tune` | Vue performance optimization |

## GitHub Actions

| Workflow | Trigger | Purpose |
|----------|---------|---------|
| `ci.yml` | Push/PR | Tests, lint, type check |
| `deploy.yml` | Push to main | Deploy to Fly.io + notify |
| `doc-test.yml` | Docs changed | Validate documentation |
| `repo-garden.yml` | Daily 2 AM UTC | Repository hygiene |
| `auto-refactor.yml` | Manual | Safe auto-refactoring |

## Commands

```bash
make install     # Install all dependencies
make dev         # Start dev servers
make lint        # Run all linters
make test        # Run all tests
make all         # Lint + test + build
```
