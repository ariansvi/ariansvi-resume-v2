#!/usr/bin/env bash
set -euo pipefail

# ─── Port Forward Cluster Services ──────────────────────────────────
# Quick access to ArgoCD, Grafana, and Prometheus

GREEN='\033[0;32m'
NC='\033[0m'

echo -e "${GREEN}Starting port-forwards...${NC}"
echo ""
echo "  ArgoCD:    https://localhost:8443"
echo "  Grafana:   http://localhost:3000"
echo "  Prometheus: http://localhost:9090"
echo ""
echo "Press Ctrl+C to stop all"
echo ""

kubectl port-forward svc/argocd-server -n argocd 8443:443 &
kubectl port-forward svc/grafana -n monitoring 3000:80 &
kubectl port-forward svc/prometheus-server -n monitoring 9090:80 &

wait
