.PHONY: frontend backend lint test all install dev setup

setup:
	@command -v pnpm >/dev/null 2>&1 || npm install -g pnpm
	@command -v uv >/dev/null 2>&1 || curl -LsSf https://astral.sh/uv/install.sh | sh

install: setup
	cd frontend && pnpm install
	cd backend && uv sync

dev:
	@echo "Run in separate terminals:"
	@echo "  make dev-frontend"
	@echo "  make dev-backend"

dev-frontend:
	cd frontend && pnpm dev

dev-backend:
	cd backend && uv run uvicorn main:app --reload

frontend:
	cd frontend && pnpm build

backend:
	cd backend && uv run pytest

lint:
	cd frontend && pnpm lint
	cd backend && uv run ruff check .
	cd backend && uv run mypy .

test: backend
	cd frontend && pnpm test --run

all: lint test frontend
