.PHONY: help build test lint clean dev tf-plan tf-apply tf-destroy

SHELL := /bin/bash
PROJECT_ID ?= arian-svirsky-resume
REGION ?= us-central1
REGISTRY ?= $(REGION)-docker.pkg.dev/$(PROJECT_ID)/resume
FRONTEND_IMAGE ?= $(REGISTRY)/frontend
BACKEND_IMAGE ?= $(REGISTRY)/backend
TAG ?= $(shell git rev-parse --short HEAD)

help: ## Show this help
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | \
		awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-20s\033[0m %s\n", $$1, $$2}'

# ─── Local Development ───────────────────────────────────────────────

dev: ## Start local development environment (docker compose)
	docker compose up --build

dev-frontend: ## Start only Hugo dev server
	cd app/frontend && hugo server -D --bind 0.0.0.0

dev-backend: ## Start only FastAPI dev server
	cd app/backend && uvicorn app.main:app --reload --host 0.0.0.0 --port 8000

# ─── Build ───────────────────────────────────────────────────────────

build: build-frontend build-backend ## Build all Docker images

build-frontend:
	docker build -t $(FRONTEND_IMAGE):$(TAG) -t $(FRONTEND_IMAGE):latest app/frontend/

build-backend:
	docker build -t $(BACKEND_IMAGE):$(TAG) -t $(BACKEND_IMAGE):latest app/backend/

push: push-frontend push-backend ## Push all images

push-frontend:
	docker push $(FRONTEND_IMAGE):$(TAG)
	docker push $(FRONTEND_IMAGE):latest

push-backend:
	docker push $(BACKEND_IMAGE):$(TAG)
	docker push $(BACKEND_IMAGE):latest

# ─── Cloud Run deploy (usually done by CI) ───────────────────────────

deploy: ## Deploy current image tags to Cloud Run
	gcloud run deploy resume-backend  --image $(BACKEND_IMAGE):$(TAG)  --region $(REGION) --quiet
	gcloud run deploy resume-frontend --image $(FRONTEND_IMAGE):$(TAG) --region $(REGION) --quiet

# ─── Testing ─────────────────────────────────────────────────────────

test: test-backend lint ## Run all tests

test-backend:
	cd app/backend && python -m pytest tests/ -v --tb=short

lint: lint-python lint-docker

lint-python:
	cd app/backend && python -m flake8 app/ tests/ --max-line-length=88
	cd app/backend && python -m mypy app/ --ignore-missing-imports

lint-docker:
	docker run --rm -i hadolint/hadolint < app/frontend/Dockerfile || true
	docker run --rm -i hadolint/hadolint < app/backend/Dockerfile || true

# ─── Terraform ───────────────────────────────────────────────────────

tf-init:
	cd terraform && terraform init

tf-plan: ## Plan Terraform changes
	cd terraform && terraform plan

tf-apply: ## Apply Terraform changes
	cd terraform && terraform apply

tf-destroy: ## Destroy all Terraform-managed resources
	cd terraform && terraform destroy

# ─── Cleanup ─────────────────────────────────────────────────────────

clean: ## Remove build artifacts
	rm -rf app/frontend/public/
	rm -rf app/backend/__pycache__/
	rm -rf app/backend/.pytest_cache/
	docker compose down --rmi local 2>/dev/null || true
