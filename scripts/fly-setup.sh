#!/usr/bin/env bash
set -e

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

log() { echo -e "${GREEN}[✓]${NC} $1"; }
warn() { echo -e "${YELLOW}[!]${NC} $1"; }
error() { echo -e "${RED}[✗]${NC} $1"; exit 1; }
step() { echo -e "\n${GREEN}==>${NC} $1\n"; }

ENV_FILE="${1:-.env.fly}"

if [ ! -f "$ENV_FILE" ]; then
    error "Config file not found: $ENV_FILE\nRun: cp .env.fly.example .env.fly && edit .env.fly"
fi

source "$ENV_FILE"

[ -z "$FLY_APP_API" ] && error "FLY_APP_API not set in $ENV_FILE"
[ -z "$FLY_APP_WEB" ] && error "FLY_APP_WEB not set in $ENV_FILE"
[ -z "$FLY_REGION" ] && FLY_REGION="nrt"

step "Step 1/6: Check Fly.io CLI"
if ! command -v fly &> /dev/null; then
    warn "flyctl not found. Installing..."
    curl -L https://fly.io/install.sh | sh
    export PATH="$HOME/.fly/bin:$PATH"
fi
log "flyctl installed: $(fly version)"

step "Step 2/6: Authenticate"
if ! fly auth whoami &> /dev/null; then
    warn "Not logged in. Opening browser..."
    fly auth login
fi
log "Logged in as: $(fly auth whoami)"

step "Step 3/6: Create Apps"
if fly apps list | grep -q "$FLY_APP_API"; then
    log "Backend app exists: $FLY_APP_API"
else
    fly apps create "$FLY_APP_API" --org personal
    log "Created backend app: $FLY_APP_API"
fi

if fly apps list | grep -q "$FLY_APP_WEB"; then
    log "Frontend app exists: $FLY_APP_WEB"
else
    fly apps create "$FLY_APP_WEB" --org personal
    log "Created frontend app: $FLY_APP_WEB"
fi

step "Step 4/6: Set Secrets"
./scripts/fly-secrets.sh "$ENV_FILE"

step "Step 5/6: Deploy"
echo "Deploying backend..."
fly deploy --config infra/fly.backend.toml --app "$FLY_APP_API" --remote-only

echo "Deploying frontend..."
fly deploy --config infra/fly.frontend.toml --app "$FLY_APP_WEB" --remote-only

step "Step 6/6: Generate Deploy Token for CI/CD"
echo ""
echo "Run this command to get your deploy token:"
echo ""
echo "  fly tokens create deploy -x 999999h"
echo ""
echo "Then add it to GitHub Secrets as FLY_API_TOKEN:"
echo "  https://github.com/YOUR_USER/YOUR_REPO/settings/secrets/actions"
echo ""

step "Setup Complete!"
echo ""
echo "  Backend:  https://${FLY_APP_API}.fly.dev"
echo "  Frontend: https://${FLY_APP_WEB}.fly.dev"
echo "  Health:   https://${FLY_APP_API}.fly.dev/health"
echo ""
log "Done!"
