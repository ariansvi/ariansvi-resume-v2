.PHONY: help build test lint clean dev deploy-dev deploy-prod tf-plan tf-apply bootstrap teardown

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

dev: ## Start local development environment
	docker compose up --build

dev-frontend: ## Start only Hugo dev server
	cd app/frontend && hugo server -D --bind 0.0.0.0

dev-backend: ## Start only FastAPI dev server
	cd app/backend && uvicorn app.main:app --reload --host 0.0.0.0 --port 8000

# ─── Build ───────────────────────────────────────────────────────────

build: build-frontend build-backend ## Build all Docker images

build-frontend: ## Build frontend Docker image
	docker build -t $(FRONTEND_IMAGE):$(TAG) -t $(FRONTEND_IMAGE):latest app/frontend/

build-backend: ## Build backend Docker image
	docker build -t $(BACKEND_IMAGE):$(TAG) -t $(BACKEND_IMAGE):latest app/backend/

push: push-frontend push-backend ## Push all images to registry

push-frontend: ## Push frontend image
	docker push $(FRONTEND_IMAGE):$(TAG)
	docker push $(FRONTEND_IMAGE):latest

push-backend: ## Push backend image
	docker push $(BACKEND_IMAGE):$(TAG)
	docker push $(BACKEND_IMAGE):latest

# ─── Testing ─────────────────────────────────────────────────────────

test: test-backend lint ## Run all tests

test-backend: ## Run backend pytest suite
	cd app/backend && python -m pytest tests/ -v --tb=short

lint: lint-python lint-docker ## Run all linters

lint-python: ## Lint Python code
	cd app/backend && python -m flake8 app/ tests/ --max-line-length=88
	cd app/backend && python -m mypy app/ --ignore-missing-imports

lint-docker: ## Lint Dockerfiles
	docker run --rm -i hadolint/hadolint < app/frontend/Dockerfile || true
	docker run --rm -i hadolint/hadolint < app/backend/Dockerfile || true

# ─── Terraform ───────────────────────────────────────────────────────

tf-init: ## Initialize Terraform
	cd terraform && terraform init

tf-plan: ## Plan Terraform changes
	cd terraform && terraform plan -var-file=environments/prod/terraform.tfvars

tf-apply: ## Apply Terraform changes
	cd terraform && terraform apply -var-file=environments/prod/terraform.tfvars

tf-destroy: ## Destroy Terraform resources
	cd terraform && terraform destroy -var-file=environments/prod/terraform.tfvars

# ─── Cluster Operations ─────────────────────────────────────────────

bootstrap: ## Full bootstrap: Terraform + ArgoCD + cluster services
	@echo "🚀 Bootstrapping cluster..."
	bash scripts/bootstrap.sh

teardown: ## Tear down all resources
	@echo "💥 Tearing down..."
	bash scripts/teardown.sh

port-forward: ## Port-forward ArgoCD and Grafana
	bash scripts/port-forward.sh

# ─── Kubernetes ──────────────────────────────────────────────────────

kustomize-dev: ## Build kustomize for dev
	kubectl kustomize k8s/overlays/dev

kustomize-staging: ## Build kustomize for staging
	kubectl kustomize k8s/overlays/staging

kustomize-prod: ## Build kustomize for production
	kubectl kustomize k8s/overlays/production

deploy-dev: build ## Build and deploy to dev (local k8s)
	kubectl kustomize k8s/overlays/dev | kubectl apply -f -

# ─── Cleanup ─────────────────────────────────────────────────────────

clean: ## Remove build artifacts
	rm -rf app/frontend/public/
	rm -rf app/backend/__pycache__/
	rm -rf app/backend/.pytest_cache/
	docker compose down --rmi local 2>/dev/null || true
