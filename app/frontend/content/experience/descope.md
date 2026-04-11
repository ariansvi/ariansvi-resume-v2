---
title: "Building a Multi-Cloud Identity Platform"
weight: 1
tags: ["kubernetes", "pulumi", "multi-cloud", "datadog"]
---

**Descope** — identity and authentication infrastructure

The platform serves millions of auth requests across 4 global regions. My job is making sure the infrastructure behind it is reliable, observable, and doesn't wake anyone up at night.

### The interesting parts

**Multi-cloud with Pulumi** — We run on AWS (primary) and GCP. 25+ microservices, all defined in TypeScript with Pulumi. Not Terraform — and I have opinions about why (ask me over coffee).

**Automated promotion pipeline** — Code flows through Sandbox → RC → Production with automated version cuts. RC deploys happen twice a week, production goes out weekly. The whole pipeline runs without human intervention unless something breaks.

**Observability at scale** — Datadog APM, logs, custom dashboards, SLOs across every region. When something degrades in Singapore, we know about it before the customer does.

**The supporting cast** — Temporal for workflows, RabbitMQ for messaging, Elasticsearch for search, Redis for caching, Cloudflare for CDN and WAF. Each one has its own war stories.
