#!/usr/bin/env bash
set -euo pipefail

# ─── Resume Cluster Bootstrap ───────────────────────────────────────
# Provisions infrastructure and installs cluster services
#
# Usage:
#   bash scripts/bootstrap.sh                        # Full bootstrap (project + infra + cluster)
#   bash scripts/bootstrap.sh --skip-bootstrap        # Skip GCP project creation
#   bash scripts/bootstrap.sh --skip-terraform        # Skip all Terraform

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"

REGION="${REGION:-us-central1}"
PROJECT_ID="${PROJECT_ID:-arian-svirsky-resume}"
CLUSTER_NAME="${CLUSTER_NAME:-resume-cluster}"

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

log()  { echo -e "${GREEN}[+]${NC} $*"; }
warn() { echo -e "${YELLOW}[!]${NC} $*"; }
err()  { echo -e "${RED}[x]${NC} $*" >&2; }

check_dependencies() {
    local deps=(gcloud terraform kubectl helm)
    for dep in "${deps[@]}"; do
        if ! command -v "$dep" &>/dev/null; then
            err "Missing dependency: $dep"
            exit 1
        fi
    done
    log "All dependencies found"
}

run_bootstrap_terraform() {
    if [[ "${SKIP_BOOTSTRAP:-}" == "true" ]]; then
        warn "Skipping bootstrap Terraform (--skip-bootstrap)"
        return 0
    fi

    log "=== Phase 0: Bootstrap GCP Project ==="
    echo ""
    echo "  This creates the GCP project, enables APIs, and creates the"
    echo "  Terraform state bucket. You only need to run this once."
    echo ""

    # Get billing account
    BILLING_ACCOUNT="${BILLING_ACCOUNT:-}"
    if [[ -z "$BILLING_ACCOUNT" ]]; then
        log "Available billing accounts:"
        gcloud billing accounts list --format="table(name, displayName, open)" 2>/dev/null || true
        echo ""
        read -rp "Enter billing account ID (XXXXXX-XXXXXX-XXXXXX): " BILLING_ACCOUNT
    fi

    if [[ -z "$BILLING_ACCOUNT" ]]; then
        err "Billing account is required"
        exit 1
    fi

    cd "$PROJECT_ROOT/terraform/bootstrap"
    terraform init

    log "Planning bootstrap..."
    terraform plan -var "billing_account=${BILLING_ACCOUNT}" -out=tfplan

    read -rp "Create GCP project and state bucket? (y/N): " confirm
    if [[ "$confirm" =~ ^[Yy]$ ]]; then
        terraform apply tfplan
        log "Bootstrap complete!"

        # Extract project number for GitHub Actions
        PROJECT_NUMBER=$(terraform output -raw project_number 2>/dev/null || echo "unknown")
        echo ""
        echo -e "  ${YELLOW}IMPORTANT: Save this as a GitHub Actions secret:${NC}"
        echo -e "  ${GREEN}GCP_PROJECT_NUMBER=${PROJECT_NUMBER}${NC}"
        echo ""
    else
        warn "Bootstrap skipped"
    fi

    cd "$PROJECT_ROOT"
}

setup_gcp_project() {
    log "Setting GCP project to ${PROJECT_ID}"
    gcloud config set project "$PROJECT_ID"
}

run_terraform() {
    if [[ "${SKIP_TERRAFORM:-}" == "true" ]]; then
        warn "Skipping Terraform (--skip-terraform)"
        return 0
    fi

    log "=== Phase 1: Infrastructure ==="

    cd "$PROJECT_ROOT/terraform"
    terraform init

    log "Planning Terraform changes..."
    terraform plan -var-file=environments/prod/terraform.tfvars -out=tfplan

    read -rp "Apply Terraform plan? (y/N): " confirm
    if [[ "$confirm" =~ ^[Yy]$ ]]; then
        terraform apply tfplan
    else
        warn "Terraform apply skipped"
        return 0
    fi

    cd "$PROJECT_ROOT"
}

configure_kubectl() {
    log "Configuring kubectl for ${CLUSTER_NAME}..."
    gcloud container clusters get-credentials "$CLUSTER_NAME" \
        --region "$REGION" \
        --project "$PROJECT_ID"

    log "Cluster info:"
    kubectl cluster-info
}

install_argocd() {
    log "Installing ArgoCD..."
    kubectl create namespace argocd --dry-run=client -o yaml | kubectl apply -f -

    helm repo add argo https://argoproj.github.io/argo-helm
    helm repo update

    helm upgrade --install argocd argo/argo-cd \
        --namespace argocd \
        --set server.service.type=ClusterIP \
        --set server.resources.requests.cpu=100m \
        --set server.resources.requests.memory=128Mi \
        --set server.resources.limits.cpu=500m \
        --set server.resources.limits.memory=256Mi \
        --set controller.resources.requests.cpu=100m \
        --set controller.resources.requests.memory=256Mi \
        --set controller.resources.limits.cpu=500m \
        --set controller.resources.limits.memory=512Mi \
        --wait --timeout 5m

    log "Waiting for ArgoCD to be ready..."
    kubectl wait --for=condition=available deployment/argocd-server \
        -n argocd --timeout=300s

    ARGOCD_PASSWORD=$(kubectl -n argocd get secret argocd-initial-admin-secret \
        -o jsonpath="{.data.password}" | base64 -d)

    log "ArgoCD installed!"
    echo ""
    echo "  URL:      kubectl port-forward svc/argocd-server -n argocd 8443:443"
    echo "  Username: admin"
    echo "  Password: ${ARGOCD_PASSWORD}"
    echo ""
}

deploy_app_of_apps() {
    log "Deploying app-of-apps to ArgoCD..."
    kubectl apply -f "$PROJECT_ROOT/k8s/argocd/app-of-apps.yaml"
    log "ArgoCD will now sync all applications automatically"
}

install_cert_issuer() {
    log "Creating Let's Encrypt ClusterIssuer..."
    kubectl apply -f - <<EOF
apiVersion: cert-manager.io/v1
kind: ClusterIssuer
metadata:
  name: letsencrypt-prod
spec:
  acme:
    server: https://acme-v02.api.letsencrypt.org/directory
    email: arian@ariansvi.com
    privateKeySecretRef:
      name: letsencrypt-prod
    solvers:
      - http01:
          ingress:
            class: nginx
EOF
    log "ClusterIssuer created"
}

# ─── Main ────────────────────────────────────────────────────────────

main() {
    # Parse flags
    for arg in "$@"; do
        case "$arg" in
            --skip-bootstrap)  SKIP_BOOTSTRAP=true ;;
            --skip-terraform)  SKIP_TERRAFORM=true; SKIP_BOOTSTRAP=true ;;
        esac
    done

    log "Starting bootstrap for arian-svirsky-resume..."
    echo ""

    check_dependencies
    run_bootstrap_terraform
    setup_gcp_project
    run_terraform
    configure_kubectl
    install_argocd
    deploy_app_of_apps

    # Wait for cert-manager to be ready before creating issuer
    log "Waiting for cert-manager..."
    sleep 30
    kubectl wait --for=condition=available deployment/cert-manager \
        -n cert-manager --timeout=300s 2>/dev/null || warn "cert-manager not ready yet, run install_cert_issuer manually"
    install_cert_issuer

    echo ""
    log "Bootstrap complete!"
    echo ""
    echo "  Next steps:"
    echo "  1. Update GoDaddy NS records (run: bash scripts/setup-dns.sh)"
    echo "  2. Port-forward ArgoCD: kubectl port-forward svc/argocd-server -n argocd 8443:443"
    echo "  3. Port-forward Grafana: kubectl port-forward svc/grafana -n monitoring 3000:80"
    echo ""
}

main "$@"
