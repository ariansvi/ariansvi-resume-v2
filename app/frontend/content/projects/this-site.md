---
title: "This Website — A DevOps Showcase"
tags: ["kubernetes", "terraform", "argocd", "docker", "github-actions", "python"]
---

This resume website is a living DevOps project that demonstrates production-grade infrastructure practices.

## Architecture Pipeline

```
 ┌──────────┐    ┌──────────┐    ┌──────────┐    ┌──────────┐    ┌──────────┐
 │  1.CODE  │───▶│ 2.BUILD  │───▶│ 3.DEPLOY │───▶│ 4.SERVE  │───▶│5.MONITOR │
 │          │    │          │    │          │    │          │    │          │
 │ Hugo     │    │ GitHub   │    │ ArgoCD   │    │ GKE      │    │Prometheus│
 │ FastAPI  │    │ Actions  │    │ GitOps   │    │Autopilot │    │ Grafana  │
 │ Terraform│    │ Docker   │    │ Kustomize│    │ Ingress  │    │ Alerts   │
 │ K8s YAML │    │ pytest   │    │ Auto-sync│    │ TLS/SSL  │    │Dashboards│
 └──────────┘    └──────────┘    └──────────┘    └──────────┘    └──────────┘

 ┌─────────────────────────────────────────────────────────────────────────────┐
 │          INFRASTRUCTURE LAYER — managed by Terraform                       │
 │  GKE Autopilot │ VPC + DNS │ Artifact Registry │ IAM + OIDC │ GCS Buckets │
 └─────────────────────────────────────────────────────────────────────────────┘

                         ~5 min from git push to live
```

## How It Works

1. **Code** — Push to `main` branch (Hugo frontend, FastAPI backend, Terraform, K8s manifests)
2. **Build** — GitHub Actions lints, tests, builds Docker images, pushes to Artifact Registry
3. **Deploy** — CI updates image tags in Git → ArgoCD detects change → rolls out to GKE
4. **Serve** — GKE Autopilot runs the pods behind Ingress-NGINX with Let's Encrypt TLS
5. **Monitor** — Prometheus scrapes metrics, Grafana dashboards track uptime and resources

## Tech Stack

| Layer | Technology |
|-------|-----------|
| IaC | Terraform (GKE, VPC, DNS, IAM, Artifact Registry) |
| Container | Docker multi-stage builds |
| Orchestration | GKE Autopilot (free-tier management) |
| Deployment | ArgoCD GitOps + GitHub Actions CI/CD |
| Frontend | Hugo static site + Nginx |
| Backend | Python FastAPI + SQLite |
| Ingress | Ingress-NGINX + cert-manager (Let's Encrypt) |
| Monitoring | Prometheus + Grafana |
| Manifests | Kustomize (base + overlays) |
| Security | Workload Identity, OIDC, NetworkPolicies, RBAC |

## Source Code

Everything is open source: [github.com/ariansvi/ariansvi-resume-v2](https://github.com/ariansvi/ariansvi-resume-v2)
