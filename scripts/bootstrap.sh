#!/usr/bin/env bash
set -euo pipefail

# ─── Resume Cluster Bootstrap ───────────────────────────────────────
# Provisions infrastructure and installs cluster services
# Usage: bash scripts/bootstrap.sh [--skip-terraform]

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"

REGION="${REGION:-us-central1}"
PROJECT_ID="${PROJECT_ID:-ariansvi-resume}"
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

setup_gcp_project() {
    log "Setting GCP project to ${PROJECT_ID}"
    gcloud config set project "$PROJECT_ID"

    log "Enabling required APIs..."
    gcloud services enable \
        container.googleapis.com \
        artifactregistry.googleapis.com \
        dns.googleapis.com \
        iam.googleapis.com \
        compute.googleapis.com \
        --quiet
}

run_terraform() {
    if [[ "${1:-}" == "--skip-terraform" ]]; then
        warn "Skipping Terraform (--skip-terraform)"
        return 0
    fi

    log "Initializing Terraform..."
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
    log "Starting bootstrap for ariansvi-resume..."
    echo ""

    check_dependencies
    setup_gcp_project
    run_terraform "$@"
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
