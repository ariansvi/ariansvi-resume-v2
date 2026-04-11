---
title: "Palo Alto Networks — VM to Kubernetes Migration"
weight: 2
tags: ["kubernetes", "docker", "aws", "jenkins", "security"]
---

**Aug 2018 – Sep 2024** | 6 years | Palo Alto Networks (Demisto → Cortex XSOAR)

Joined Demisto pre-acquisition, stayed through the Palo Alto Networks integration, grew from DevOps Engineer to Principal.

### The big project: EC2 → Kubernetes

Led the migration of the entire Cortex XSOAR platform from AWS EC2 VMs to Kubernetes. This wasn't a straightforward lift-and-shift — XSOAR is a SOAR product that runs customer automation playbooks inside Docker containers.

**The DIND challenge:** The platform needs to spin up Docker containers dynamically (customer integrations run in isolated containers). Running Docker-in-Docker on Kubernetes with proper security isolation was the hardest problem I've solved. We had to balance:
- Container escape prevention (this is a security product)
- Dynamic container scheduling inside K8s pods
- Resource isolation between customer workloads
- Network policies for multi-tenant isolation

### Other things I built

- CI/CD pipeline infrastructure — Jenkins shared libraries, GitLab CI, later migrated parts to GitHub Actions
- Integrated Demisto's infrastructure into the Palo Alto Networks ecosystem post-acquisition
- Terraform modules for AWS infrastructure (VPC, EKS, RDS, S3)
- Monitoring stack evolution: Nagios → Prometheus + Grafana
- Mentored junior DevOps engineers as Principal
