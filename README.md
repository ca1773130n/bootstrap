# Bootstrap

Minimal Vue 3 + FastAPI starter. Deploy to Fly.io in minutes.

## Stack

- **Frontend**: Vue 3 + Vite + TypeScript
- **Backend**: FastAPI + Pydantic
- **Database**: PostgreSQL (self-hosted on VPS)
- **Hosting**: Fly.io
- **CI**: GitHub Actions

## Quick Start

### 1. Clone and Initialize

```bash
git clone https://github.com/YOUR_USER/bootstrap.git myproject
cd myproject

# Initialize with your app name
./scripts/init.sh myproject
```

### 2. Local Development

```bash
# Install dependencies
make install

# Start with Docker
make up

# Or run separately
make dev-frontend  # Terminal 1: http://localhost:5173
make dev-backend   # Terminal 2: http://localhost:8000
```

### 3. Set Up Database (Oracle Cloud Free Tier)

See [extras/infra-fly/postgres-vps.md](extras/infra-fly/postgres-vps.md) for full guide.

```bash
# SSH into your VPS
ssh opc@YOUR_VPS_IP

# Install PostgreSQL
sudo dnf install -y postgresql-server postgresql-contrib
sudo postgresql-setup --initdb
sudo systemctl enable --now postgresql

# Create database
sudo -u postgres psql
CREATE USER appuser WITH PASSWORD 'your-password';
CREATE DATABASE appdb OWNER appuser;
\q

# Allow remote connections (see postgres-vps.md for details)
```

### 4. Deploy to Fly.io

```bash
# Edit .env.fly with your database URL
nano .env.fly

# Deploy everything
./extras/infra-fly/fly-setup.sh
```

Your app will be live at:
- Frontend: `https://myproject-web.fly.dev`
- Backend: `https://myproject-api.fly.dev`

## Project Structure

```
├── frontend/              # Vue 3 + Vite + TypeScript
├── backend/               # FastAPI + Pydantic
├── infra/                 # Database schema
├── scripts/
│   └── init.sh            # Project initialization
├── extras/
│   └── infra-fly/         # Fly.io deployment
│       ├── fly-setup.sh   # One-command deploy
│       ├── fly.*.toml     # Fly configs
│       └── postgres-vps.md # Database setup guide
├── docker-compose.yml     # Local development
└── Makefile               # Common commands
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

## Environment Variables

### Backend

| Variable | Description |
|----------|-------------|
| `DATABASE_URL` | PostgreSQL connection string |
| `SECRET_KEY` | App secret key |
| `CORS_ORIGINS` | Allowed CORS origins (comma-separated) |

### Frontend (Build-time)

| Variable | Description |
|----------|-------------|
| `VITE_API_URL` | Backend API URL |

## Deployment

The `./scripts/init.sh` script configures your app name across all config files. Then `./extras/infra-fly/fly-setup.sh` handles:

1. Installing Fly CLI
2. Authentication
3. Creating Fly apps
4. Setting secrets
5. Building and deploying

## Extras

| Folder | Purpose |
|--------|---------|
| `extras/infra-fly/` | Fly.io deployment + PostgreSQL VPS guide |
| `extras/workflows/` | Additional GitHub Actions |
| `extras/agents/` | AI agent definitions |
| `extras/constitution/` | AI governance rules |
| `extras/claude-skills/` | Claude Code skills |
