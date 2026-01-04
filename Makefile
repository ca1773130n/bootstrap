.PHONY: setup install dev dev-frontend dev-backend up down lint test build all
.PHONY: openapi new-feature feature-up feature-down feature-clean
.PHONY: test-adversarial test-mutation test-properties
.PHONY: doc-sync

# === Setup ===
setup:
	@command -v pnpm >/dev/null 2>&1 || npm install -g pnpm
	@command -v uv >/dev/null 2>&1 || curl -LsSf https://astral.sh/uv/install.sh | sh

install: setup
	cd frontend && pnpm install
	cd backend && uv sync --all-extras

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

# === Feature Development ===
new-feature:
	@./scripts/new-feature.sh $(NAME)

feature-up:
	docker compose --env-file .env.local up -d

feature-down:
	docker compose --env-file .env.local down

feature-clean:
	docker compose --env-file .env.local down -v
	rm -f .env.local

# === API Generation ===
openapi:
	cd backend && uv run python scripts/export_openapi.py
	cd frontend && pnpm generate:api

# === Quality ===
lint:
	cd frontend && pnpm lint
	cd backend && uv run ruff check .
	cd backend && uv run mypy .

test:
	cd backend && uv run pytest
	cd frontend && pnpm test:coverage

test-properties:
	cd backend && uv run pytest tests/test_properties.py -v

test-mutation:
	cd backend && chmod +x scripts/mutation-test.sh && ./scripts/mutation-test.sh
	cd frontend && pnpm test:mutation

test-adversarial:
	@echo "Phase 1: Coverage Tests"
	cd backend && uv run pytest --cov-fail-under=100
	cd frontend && pnpm test:coverage
	@echo ""
	@echo "Phase 2: Property-Based Tests"
	cd backend && uv run pytest tests/test_properties.py -v
	@echo ""
	@echo "Phase 3: Mutation Tests"
	$(MAKE) test-mutation
	@echo ""
	@echo "All adversarial tests passed!"

build:
	cd frontend && pnpm build

all: lint test build

# === Documentation ===
doc-sync:
	@echo "Running documentation sync for HEAD..."
	@if command -v opencode >/dev/null 2>&1; then \
		opencode --prompt "/doc-sync HEAD"; \
	else \
		echo "Error: opencode not found"; \
		echo "Install: npm install -g @anthropic/opencode"; \
		echo "Or run /doc-sync manually in your AI assistant"; \
		exit 1; \
	fi
