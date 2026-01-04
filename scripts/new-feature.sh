#!/usr/bin/env bash
set -euo pipefail

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

FEATURE_NAME="${1:-}"
if [[ -z "$FEATURE_NAME" ]]; then
    echo "Usage: ./scripts/new-feature.sh <feature-name>"
    echo "Example: ./scripts/new-feature.sh user-auth"
    exit 1
fi

SAFE_NAME=$(echo "$FEATURE_NAME" | tr '[:upper:]' '[:lower:]' | sed 's/[^a-z0-9-]/-/g')

if command -v md5sum &> /dev/null; then
    HASH=$(echo -n "$SAFE_NAME" | md5sum | head -c 4)
elif command -v md5 &> /dev/null; then
    HASH=$(echo -n "$SAFE_NAME" | md5 | head -c 4)
else
    HASH=$(echo -n "$SAFE_NAME" | cksum | cut -d' ' -f1 | head -c 4)
fi

PORT_OFFSET=$((16#${HASH} % 900 + 100))
DB_PORT=$((5432 + PORT_OFFSET))
BACKEND_PORT=$((8000 + PORT_OFFSET))
FRONTEND_PORT=$((5173 + PORT_OFFSET))
DB_SCHEMA="feature_${SAFE_NAME//-/_}"

git checkout -b "feature/${SAFE_NAME}" 2>/dev/null || git checkout "feature/${SAFE_NAME}"

cat > .env.local << EOF
COMPOSE_PROJECT_NAME=bootstrap-${SAFE_NAME}
DB_PORT=${DB_PORT}
DB_NAME=app
DB_SCHEMA=${DB_SCHEMA}
BACKEND_PORT=${BACKEND_PORT}
FRONTEND_PORT=${FRONTEND_PORT}
EOF

echo -e "${GREEN}Feature environment: ${FEATURE_NAME}${NC}"
echo ""
echo "Ports allocated:"
echo "  Database:  localhost:${DB_PORT}"
echo "  Backend:   http://localhost:${BACKEND_PORT}"
echo "  Frontend:  http://localhost:${FRONTEND_PORT}"
echo "  Schema:    ${DB_SCHEMA}"
echo ""
echo -e "${YELLOW}Start:${NC} make feature-up"
echo -e "${YELLOW}Stop:${NC}  make feature-down"
