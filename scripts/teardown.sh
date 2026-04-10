#!/usr/bin/env bash
set -euo pipefail

# ─── Resume Cluster Teardown ────────────────────────────────────────
# Destroys all resources to save costs
# Usage: bash scripts/teardown.sh

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

log()  { echo -e "${GREEN}[+]${NC} $*"; }
warn() { echo -e "${YELLOW}[!]${NC} $*"; }

echo -e "${RED}"
echo "  ╔══════════════════════════════════════╗"
echo "  ║  WARNING: This will DESTROY all      ║"
echo "  ║  infrastructure resources!            ║"
echo "  ╚══════════════════════════════════════╝"
echo -e "${NC}"

read -rp "Type 'destroy' to confirm: " confirm
if [[ "$confirm" != "destroy" ]]; then
    warn "Aborted"
    exit 0
fi

log "Removing ArgoCD applications..."
kubectl delete -f "$PROJECT_ROOT/k8s/argocd/app-of-apps.yaml" --ignore-not-found || true

log "Waiting for ArgoCD to clean up resources..."
sleep 30

log "Destroying Terraform resources..."
cd "$PROJECT_ROOT/terraform"
terraform destroy \
    -var-file=environments/prod/terraform.tfvars \
    -auto-approve

log "Teardown complete! All resources have been destroyed."
echo ""
echo "  To re-deploy, run: bash scripts/bootstrap.sh"
