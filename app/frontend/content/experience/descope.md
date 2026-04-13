---
title: "A Multi-Cloud Identity Platform"
weight: 1
tags: ["kubernetes", "pulumi", "multi-cloud", "datadog"]
---

**Descope** — identity and authentication infrastructure

Part of the platform team behind an auth product that processes millions of requests per day across 4 global regions. My remit is the boring but load-bearing part: the infra stays up, the deploys stay boring, and production never surprises us.

### Scale & surface area

- **25+ microservices** in one platform, running simultaneously on **AWS (primary) and GCP**
- **4 regions**, each a fully independent production environment
- **Millions of auth requests/day** across customer workloads
- **TypeScript + Pulumi** as the IaC substrate — every cluster, every service, every env

### What I own and drive

**Reliability & observability** — Full Datadog footprint (APM, structured logs, dashboards, SLOs) across every region. I build and maintain the dashboards on-call actually uses, set the SLO targets for services I own, and drive the runbook standard for infra-level incidents. When latency creeps in Singapore, we see it before customers do.

**Deployment pipeline** — Automated Sandbox → RC → Production promotion. RC ships twice a week, production weekly, hands-off unless something actually breaks. I contribute to the pipeline design and own the infrastructure changes that flow through it.

**Platform IaC patterns** — Module design, environment promotion, guardrails. I write the Pulumi modules other teams consume and review cross-service infrastructure changes.

**Supporting systems** — Temporal (workflows), RabbitMQ (messaging), Elasticsearch (search), Redis (caching), Cloudflare (CDN + WAF). I'm the operational owner on the pieces that don't have a product team behind them.

### Why it's interesting

This isn't one cluster with some apps on it — it's a small-ish SaaS platform that happens to run in two clouds at the same time, with enterprise customers expecting five-nines behavior. The problems that matter aren't "how do I deploy to Kubernetes"; they're "how do I evolve the platform without freezing a release train" and "how do I know a regional provider issue from a regression we shipped."
