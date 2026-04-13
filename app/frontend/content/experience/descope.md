---
title: "Leading a Multi-Cloud Identity Platform"
weight: 1
tags: ["kubernetes", "pulumi", "multi-cloud", "datadog"]
---

**Descope** — identity and authentication infrastructure

I operate and evolve the infrastructure behind Descope's identity platform. The platform handles millions of auth requests across 4 global regions; my focus is reliability, scalability, and observability.

### What I work on

**Multi-cloud Kubernetes platform** — Operate a 25+ microservice platform running on AWS (primary) and GCP across 4 regions. All infrastructure is defined in TypeScript with Pulumi; I contribute to module design, the environment promotion model, and platform guardrails.

**Automated promotion pipeline** — Contribute to the Sandbox → RC → Production pipeline with automated version cuts. RC deploys ship twice a week, production weekly, fully hands-off unless something breaks.

**Observability and SLOs at scale** — Build and maintain Datadog APM, structured logs, custom dashboards, and SLOs across every region. Help define on-call runbooks and reliability reviews.

**Infrastructure best practices** — Define and document IaC patterns, deployment standards, and incident response processes. Review cross-service infrastructure changes and contribute to architectural discussions.

**Core supporting stack** — Temporal for workflows, RabbitMQ for messaging, Elasticsearch for search, Redis for caching, Cloudflare for CDN and WAF. I own the operational posture on all of them.
