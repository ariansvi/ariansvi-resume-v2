---
title: "Migrating a Security Product to Kubernetes"
weight: 2
tags: ["kubernetes", "docker", "security", "migration"]
---

**Palo Alto Networks** (Cortex XSOAR, formerly Demisto) — 6 years

Joined Demisto as a DevOps Engineer, stayed through the Palo Alto Networks acquisition, left as Principal DevOps Engineer.

### The hard problem: Docker-in-Docker on Kubernetes

Cortex XSOAR is a SOAR product — it runs customer automation playbooks inside Docker containers. When we moved from EC2 to Kubernetes, the big question was: how do you securely run Docker-in-Docker inside Kubernetes pods?

This isn't a "just add privileged mode" situation. This is a security product. Customers run untrusted integration code. Container escapes aren't theoretical — they're the threat model.

We solved it with a combination of:
- Custom container runtime configuration
- Network policies for strict workload isolation
- Resource limits that actually work under dynamic scheduling
- A security review process that would make most companies cry

It took months, broke things, and taught me more about container security than any certification ever could.

### The rest of the 6 years

- Built the CI/CD pipeline from Jenkins to GitLab CI
- Terraform'd all of AWS (VPC, EKS, RDS, S3, the works)
- Evolved monitoring from Nagios to Prometheus + Grafana
- Integrated Demisto's infrastructure into the Palo Alto Networks ecosystem post-acquisition
- Eventually became Principal — meaning I got to make architecture decisions and mentor the team
