#!/usr/bin/env bash
set -euo pipefail

# ─── Build and Push Docker Images ────────────────────────────────────
# Usage: bash scripts/build-images.sh [TAG]

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"

REGION="${REGION:-us-central1}"
PROJECT_ID="${PROJECT_ID:-ariansvi-resume}"
REGISTRY="${REGION}-docker.pkg.dev/${PROJECT_ID}/resume"
TAG="${1:-$(git rev-parse --short HEAD)}"

GREEN='\033[0;32m'
NC='\033[0m'
log() { echo -e "${GREEN}[+]${NC} $*"; }

log "Building images with tag: ${TAG}"

log "Configuring Docker for Artifact Registry..."
gcloud auth configure-docker "${REGION}-docker.pkg.dev" --quiet

log "Building frontend..."
docker build \
    -t "${REGISTRY}/frontend:${TAG}" \
    -t "${REGISTRY}/frontend:latest" \
    "${PROJECT_ROOT}/app/frontend/"

log "Building backend..."
docker build \
    -t "${REGISTRY}/backend:${TAG}" \
    -t "${REGISTRY}/backend:latest" \
    "${PROJECT_ROOT}/app/backend/"

log "Pushing frontend..."
docker push "${REGISTRY}/frontend:${TAG}"
docker push "${REGISTRY}/frontend:latest"

log "Pushing backend..."
docker push "${REGISTRY}/backend:${TAG}"
docker push "${REGISTRY}/backend:latest"

log "Done! Images pushed:"
echo "  ${REGISTRY}/frontend:${TAG}"
echo "  ${REGISTRY}/backend:${TAG}"
