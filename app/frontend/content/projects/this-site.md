---
title: "This Website — A DevOps Showcase"
date: 2024-06-01
tags: ["kubernetes", "terraform", "argocd", "docker", "github-actions", "python"]
---

This resume website is a living DevOps project that demonstrates production-grade infrastructure practices.

## Architecture

```
                    ┌──────────────┐
                    │   GoDaddy    │
                    │  ariansvi.com│
                    └──────┬───────┘
                           │ NS delegation
                    ┌──────▼───────┐
                    │  Cloud DNS   │
                    └──────┬───────┘
                           │
                    ┌──────▼───────┐
                    │ Ingress-NGINX│
                    │ + cert-mgr   │
                    │ (Let's Encrypt)
                    └──┬────────┬──┘
                       │        │
              ┌────────▼──┐  ┌──▼────────┐
              │  Frontend  │  │  Backend   │
              │  (Hugo +   │  │ (FastAPI + │
              │   Nginx)   │  │  SQLite)   │
              └────────────┘  └────────────┘
```

## Tech Stack

| Layer | Technology |
|-------|-----------|
| IaC | Terraform (GKE, VPC, DNS, IAM) |
| Container | Docker multi-stage builds |
| Orchestration | GKE Autopilot |
| Deployment | ArgoCD (GitOps, app-of-apps) |
| CI/CD | GitHub Actions (lint, test, build, deploy) |
| Frontend | Hugo static site + Nginx |
| Backend | Python FastAPI + SQLite |
| Ingress | Ingress-NGINX + cert-manager |
| Monitoring | Prometheus + Grafana |
| Manifests | Kustomize (base + overlays) |

## Source Code

Everything is open source: [github.com/ariansvi/ariansvi-resume-v2](https://github.com/ariansvi/ariansvi-resume-v2)
