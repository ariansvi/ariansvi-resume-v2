---
title: "ariansvi.com — Cloud-Native on a Budget"
tags: ["cloud-run", "terraform", "firestore", "github-actions", "python"]
---

A personal website that runs on the same infrastructure patterns I use in production — but tuned to cost less than a coffee per month instead of a small car.

### How it works

```
  git push  →  GitHub Actions  →  Artifact Registry  →  Cloud Run
              (lint, test, build)  (Docker images)     (serverless, scales to zero)
```

Push code → GitHub Actions lints + tests + builds Docker images → pushes to Google Artifact Registry → deploys both services to Cloud Run via `gcloud run deploy`. End-to-end in a few minutes. Auth to GCP is keyless (Workload Identity Federation).

### Tech stack

- **Infrastructure:** Terraform (Cloud Run, Firestore, Cloud DNS, Artifact Registry, IAM)
- **Frontend:** Hugo static site served by Nginx, running on Cloud Run
- **Backend:** Python FastAPI on Cloud Run, Firestore for analytics + contact messages
- **Domain & TLS:** Cloud Run domain mapping (managed certs, no LB cost)
- **CI/CD:** GitHub Actions with Workload Identity Federation — no long-lived keys
- **Previous version:** a GKE Autopilot + ArgoCD + Prometheus version is preserved on the [`archive/gke-stack`](https://github.com/ariansvi/ariansvi-resume-v2/tree/archive/gke-stack) branch

### Why the rewrite

The first version was the classic "prove you can run Kubernetes in production" stack — GKE Autopilot, ArgoCD, ingress-nginx, cert-manager, Prometheus, Grafana. It was good demo material but cost ~$120/month to run for a site that gets a few dozen visits a day. Cloud Run with scale-to-zero runs the same workload for under $5/month.

The architecture trade-off is the point: pick the right tool for the actual load, not the most impressive diagram.

### What I learned

- Cloud Run v2 with `cpu_idle = true` and `min_instance_count = 0` eliminates idle cost — cold starts on Python FastAPI with Firestore are 1-2 seconds, fine for a resume site
- Cloud Run domain mapping needs specific DNS records per service — exposing them as Terraform outputs keeps GoDaddy/Cloud DNS in sync automatically
- Firestore has no SQL-style GROUP BY; for low volume, aggregating 30 days of analytics in Python at query time is simpler than maintaining denormalized counters
- Workload Identity Federation from GitHub Actions replaces service account keys entirely — the CI never sees a credential

[Source code →](https://github.com/ariansvi/ariansvi-resume-v2)
