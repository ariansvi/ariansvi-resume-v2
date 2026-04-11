---
title: "Descope — Multi-Cloud Identity Infrastructure"
weight: 1
tags: ["kubernetes", "pulumi", "aws", "gcp", "azure", "datadog"]
---

**Sep 2024 – Present** | Descope

Building the infrastructure behind an identity and authentication platform.

### What I'm building

- **Multi-cloud K8s platform** — 25+ microservices across AWS EKS, GCP GKE, and Azure AKS, all managed with Pulumi (TypeScript)
- **4-region production** — US, EU, APAC, Canada, with automated failover
- **GitOps deployment pipeline** — GitHub Actions → version cut → staging promotion → production rollout. Automated twice-weekly RC, weekly production
- **Full observability stack** — Datadog APM, logs, custom dashboards, SLOs, and alerting across all regions
- **Infrastructure services** — Temporal workflows, RabbitMQ, Elasticsearch, Redis clusters, Cloudflare CDN + WAF

### Problems I've solved

- Reduced deployment time by 60% by redesigning the CI/CD pipeline
- Built the promotion flow from scratch: Sandbox → RC → Production with automated gates
- Designed cross-region DNS failover strategy
