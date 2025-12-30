.PHONY: setup install dev dev-frontend dev-backend up down lint test build all

# === Setup ===
setup:
	@command -v pnpm >/dev/null 2>&1 || npm install -g pnpm
	@command -v uv >/dev/null 2>&1 || curl -LsSf https://astral.sh/uv/install.sh | sh

install: setup
	cd frontend && pnpm install
	cd backend && uv sync

# === Development ===
dev:
	@echo "Run in separate terminals:"
	@echo "  make dev-frontend"
	@echo "  make dev-backend"
	@echo ""
	@echo "Or use Docker:"
	@echo "  make up"

dev-frontend:
	cd frontend && pnpm dev

dev-backend:
	cd backend && uv run uvicorn main:app --reload

# === Docker ===
up:
	docker compose up -d

down:
	docker compose down

logs:
	docker compose logs -f

# === Quality ===
lint:
	cd frontend && pnpm lint
	cd backend && uv run ruff check .
	cd backend && uv run mypy .

test:
	cd backend && uv run pytest
	cd frontend && pnpm test --run

build:
	cd frontend && pnpm build

all: lint test build
