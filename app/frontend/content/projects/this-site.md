---
title: "ariansvi.com — Over-Engineered on Purpose"
tags: ["kubernetes", "terraform", "argocd", "github-actions", "python"]
---

A personal website that runs on the same infrastructure patterns I use in production. Intentionally over-engineered — the architecture is the content.

### How it works

```
  git push  →  GitHub Actions  →  Artifact Registry  →  ArgoCD  →  GKE
              (lint, test, build)  (Docker images)     (GitOps sync)
```

The full pipeline: push code, GitHub Actions runs linting + tests + Docker builds, pushes images to Google Artifact Registry, updates the Kustomize image tags, ArgoCD detects the change and rolls out to GKE Autopilot. About 5 minutes end-to-end.

### Tech stack

- **Infrastructure:** Terraform (GKE Autopilot, VPC, Cloud DNS, IAM, Artifact Registry)
- **Frontend:** Hugo static site served by Nginx
- **Backend:** Python FastAPI with SQLite (visitor analytics, health checks)
- **Deployment:** ArgoCD (GitOps), Kustomize (base + overlays)
- **TLS:** cert-manager + Let's Encrypt (automated)
- **Monitoring:** Prometheus + Grafana
- **CI/CD:** GitHub Actions (5 parallel jobs: lint Python, lint Dockerfiles, lint Terraform, validate Kustomize, run tests)

### What I learned building it

- GKE Autopilot blocks `kube-system` leader election — cert-manager needs `global.leaderElection.namespace` set
- Hairpin NAT on GKE means cert-manager can't self-check HTTP-01 challenges from inside the cluster — solved with `hostAliases`
- NetworkPolicies with default-deny break cert-manager ACME solvers — need explicit allow rules
- Hugo module system and Go module v3 path conventions don't play well together — vendored the theme instead

[Source code →](https://github.com/ariansvi/ariansvi-resume-v2)
