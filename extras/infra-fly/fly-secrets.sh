#!/usr/bin/env bash
set -e

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

log() { echo -e "${GREEN}[✓]${NC} $1"; }
warn() { echo -e "${YELLOW}[!]${NC} $1"; }
error() { echo -e "${RED}[✗]${NC} $1"; exit 1; }

ENV_FILE="${1:-.env.fly}"

if [ ! -f "$ENV_FILE" ]; then
    error "Config file not found: $ENV_FILE"
fi

source "$ENV_FILE"

[ -z "$FLY_APP_API" ] && error "FLY_APP_API not set"

echo "Updating secrets for $FLY_APP_API..."

SECRETS=""
[ -n "$DATABASE_URL" ] && SECRETS="$SECRETS DATABASE_URL=$DATABASE_URL"
[ -n "$SECRET_KEY" ] && SECRETS="$SECRETS SECRET_KEY=$SECRET_KEY"

if [ -n "$SECRETS" ]; then
    fly secrets set $SECRETS --app "$FLY_APP_API"
    log "Backend secrets updated"
else
    warn "No secrets to set"
fi

echo ""
echo "Current secrets:"
fly secrets list --app "$FLY_APP_API"
