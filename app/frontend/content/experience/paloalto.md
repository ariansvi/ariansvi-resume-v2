---
title: "Migrating a Security Product to Kubernetes"
weight: 2
tags: ["kubernetes", "docker", "security", "migration"]
---

**Palo Alto Networks** (Cortex XSOAR, formerly Demisto) — 6 years

Joined Demisto as a DevOps Engineer, stayed through the Palo Alto Networks acquisition, left as **Principal DevOps Engineer**. Led infrastructure architecture and mentored a growing DevOps team through a startup-to-enterprise transition.

### The hard problem: Docker-in-Docker on Kubernetes

Cortex XSOAR is a SOAR product — it runs customer automation playbooks inside Docker containers. When we moved from EC2 to Kubernetes, I led the design of how to securely run Docker-in-Docker inside Kubernetes pods.

This isn't a "just add privileged mode" situation. This is a security product. Customers run untrusted integration code. Container escapes aren't theoretical — they're the threat model.

I drove the solution end-to-end:
- Designed a custom container runtime configuration to eliminate the privileged requirement
- Authored network policies for strict workload isolation
- Set resource limits that hold under dynamic scheduling
- Owned the security review process and got sign-off from the PANW security org

The migration shipped and became the standard deployment for enterprise customers.

### Ownership across 6 years

- **CI/CD architecture** — Led the migration from Jenkins to GitLab CI; defined shared-library patterns used across the R&D org
- **AWS infrastructure** — Terraformed all of AWS (VPC, EKS, RDS, S3, IAM, Route53); owned cost, security posture, and DR strategy
- **Observability transformation** — Drove migration from Nagios to Prometheus + Grafana; defined the SLO and alerting standard
- **Post-acquisition integration** — Led integration of Demisto infrastructure into the Palo Alto Networks ecosystem (IAM, networking, compliance)
- **Principal responsibilities** — Made architecture decisions, mentored engineers, and represented infrastructure in cross-org technical reviews
