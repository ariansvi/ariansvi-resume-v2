#!/usr/bin/env bash
set -euo pipefail

# ─── Istio Service Mesh — Deploy on demand ───────────────────────────
# Showcases service mesh expertise
# Usage: bash extras/istio/install.sh

GREEN='\033[0;32m'
NC='\033[0m'
log() { echo -e "${GREEN}[+]${NC} $*"; }

log "Installing Istio via istioctl..."

if ! command -v istioctl &>/dev/null; then
    log "Installing istioctl..."
    curl -L https://istio.io/downloadIstio | ISTIO_VERSION=1.23.0 sh -
    export PATH="$PWD/istio-1.23.0/bin:$PATH"
fi

log "Installing Istio with minimal profile..."
istioctl install --set profile=minimal \
    --set values.pilot.resources.requests.cpu=100m \
    --set values.pilot.resources.requests.memory=256Mi \
    -y

log "Enabling sidecar injection for resume namespace..."
kubectl label namespace resume istio-injection=enabled --overwrite

log "Applying Istio resources..."
kubectl apply -f extras/istio/virtual-service.yaml
kubectl apply -f extras/istio/destination-rule.yaml

log "Istio installed! Restart pods to inject sidecars:"
echo "  kubectl rollout restart deployment -n resume"
