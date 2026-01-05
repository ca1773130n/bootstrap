#!/usr/bin/env bash
set -e

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

log() { echo -e "${GREEN}[✓]${NC} $1"; }
warn() { echo -e "${YELLOW}[!]${NC} $1"; }
error() { echo -e "${RED}[✗]${NC} $1"; exit 1; }

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

APP_NAME="${1:-}"

if [ -z "$APP_NAME" ]; then
    echo "Usage: ./scripts/init.sh <app-name>"
    echo ""
    echo "Example: ./scripts/init.sh myproject"
    echo ""
    echo "This will:"
    echo "  - Rename 'myapp' to 'myproject' in all config files"
    echo "  - Create .env.fly from template"
    echo "  - Set up the project for deployment"
    exit 1
fi

if [[ ! "$APP_NAME" =~ ^[a-z][a-z0-9-]*$ ]]; then
    error "App name must start with a letter and contain only lowercase letters, numbers, and hyphens"
fi

echo ""
echo "Initializing project as: $APP_NAME"
echo ""

cd "$PROJECT_ROOT"

log "Updating fly.backend.toml..."
sed -i.bak "s/myapp-api/${APP_NAME}-api/g" infra/fly.backend.toml
sed -i.bak "s/myapp-web/${APP_NAME}-web/g" infra/fly.backend.toml
rm -f infra/fly.backend.toml.bak

log "Updating fly.frontend.toml..."
sed -i.bak "s/myapp-api/${APP_NAME}-api/g" infra/fly.frontend.toml
sed -i.bak "s/myapp-web/${APP_NAME}-web/g" infra/fly.frontend.toml
rm -f infra/fly.frontend.toml.bak

log "Updating .env.fly.example..."
sed -i.bak "s/myapp-api/${APP_NAME}-api/g" infra/.env.fly.example
sed -i.bak "s/myapp-web/${APP_NAME}-web/g" infra/.env.fly.example
rm -f infra/.env.fly.example.bak

if [ ! -f ".env.fly" ]; then
    log "Creating .env.fly from template..."
    cp infra/.env.fly.example .env.fly
    warn "Edit .env.fly with your database credentials before deploying"
else
    warn ".env.fly already exists, skipping..."
fi

echo ""
log "Project initialized as: $APP_NAME"
echo ""
echo "Next steps:"
echo "  1. Edit .env.fly with your DATABASE_URL and SECRET_KEY"
echo "  2. Run: ./infra/fly-setup.sh"
echo ""
echo "Your apps will be:"
echo "  - Backend: https://${APP_NAME}-api.fly.dev"
echo "  - Frontend: https://${APP_NAME}-web.fly.dev"
echo ""
