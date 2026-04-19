---
title: "Tools & Technologies"
---

Not a checklist — these are things I actually use in production and have opinions about.

## Kubernetes
EKS, GKE — I've run clusters on both. Helm for packages, Kustomize for overlays, ArgoCD for GitOps. Opinions: Autopilot is great until you need node-level access. Managed node groups are the sweet spot for most teams.

## Infrastructure as Code
Terraform for cloud resources (modules, remote state, workspaces). Pulumi when the team prefers real programming languages over HCL. I've used both in production and can argue for either depending on the context.

## CI/CD
GitHub Actions is my current default. I've also built and maintained Jenkins shared libraries and GitLab CI DAG pipelines. The best CI system is the one your team actually understands.

## Cloud

**GCP** — deepest, from 6 years running Palo Alto Networks workloads on it. GKE, GCE, Cloud SQL, GCS, Cloud DNS, IAM, VPC, Cloud Build, Pub/Sub, Workload Identity, Secret Manager. Comfortable designing a project from org-level IAM down to individual service accounts.

**AWS** — strong. Demisto ran on AWS, and I own AWS infrastructure at Descope today. EKS, EC2, RDS, S3, Lambda, Route53, IAM, VPC, ALB/NLB, Secrets Manager, ECR. Terraform-first, comfortable debugging IAM at 2am.

**Multi-cloud in production is different from using both** — at Descope I deploy the same platform to AWS and GCP simultaneously, which forces you to think about what's actually portable vs. what needs a cloud-specific shim.

## Monitoring
Datadog in production (APM, logs, dashboards, SLOs). Prometheus + Grafana for self-hosted setups. ELK when you need to search through 100GB of logs. The tool matters less than having the discipline to actually look at the dashboards.

## Databases
MySQL replication and tuning. Elasticsearch cluster management (index lifecycle, mappings, the joy of shard allocation). Redis clustering and sentinel. PostgreSQL when MySQL isn't the right fit.

## Languages
Bash for glue. Python for APIs and automation (FastAPI, boto3). TypeScript for Pulumi. Go when I need a CLI tool that compiles to a single binary.

## Linux
RHEL, Ubuntu, Alpine. systemd, kernel tuning, iptables, tcpdump. The foundation everything else runs on.
