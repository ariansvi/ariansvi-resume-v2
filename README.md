# ariansvi.com — DevOps Resume as Code

A production-grade personal resume website that **is itself** a DevOps showcase. Every layer of the stack — from infrastructure provisioning to monitoring — demonstrates real-world engineering practices.

**Live:** [https://ariansvi.com](https://ariansvi.com)

---

## Architecture

```
                         ┌─────────────┐
                         │  GoDaddy    │
                         │ ariansvi.com│
                         └──────┬──────┘
                                │ NS delegation
                         ┌──────▼──────┐
                         │  Cloud DNS  │
                         │ (Terraform) │
                         └──────┬──────┘
                                │
                    ┌───────────▼───────────┐
                    │    GKE Autopilot      │
                    │    (Terraform)        │
                    ├───────────────────────┤
                    │  ┌─────────────────┐  │
                    │  │  Ingress-NGINX  │  │
                    │  │  + cert-manager │  │
                    │  │  (Let's Encrypt)│  │
                    │  └───┬─────────┬───┘  │
                    │      │         │      │
                    │  ┌───▼───┐ ┌───▼───┐  │
                    │  │Frontend│ │Backend│  │
                    │  │ Hugo + │ │FastAPI│  │
                    │  │ Nginx  │ │SQLite │  │
                    │  └───────┘ └───────┘  │
                    │                       │
                    │  ┌─────────────────┐  │
                    │  │   Prometheus    │  │
                    │  │   + Grafana     │  │
                    │  └─────────────────┘  │
                    └───────────────────────┘
                              ▲
                    ┌─────────┴─────────┐
                    │     ArgoCD        │
                    │   (GitOps sync)   │
                    └───────────────────┘
```

## Skills Demonstrated

| Category | Technologies |
|----------|-------------|
| **Container Orchestration** | Kubernetes (GKE Autopilot), Helm, Kustomize |
| **Infrastructure as Code** | Terraform (modules, remote state, Workload Identity) |
| **CI/CD** | GitHub Actions, ArgoCD (GitOps), Jenkins (extras) |
| **Containers** | Docker (multi-stage builds, slim images) |
| **Backend** | Python FastAPI, SQLAlchemy, SQLite |
| **Monitoring** | Prometheus, Grafana (custom dashboards) |
| **Networking** | Ingress-NGINX, cert-manager, NetworkPolicies, Cloud DNS |
| **Security** | Workload Identity, RBAC, non-root containers, OIDC |
| **Databases** | SQLite (prod), MySQL (extras), Elasticsearch (extras) |
| **Service Mesh** | Istio (extras — VirtualService, DestinationRule) |
| **Scripting** | Bash (bootstrap, teardown, build scripts) |

## Quick Start

### Local Development

```bash
# Start everything with Docker Compose
make dev

# Frontend: http://localhost:8080
# Backend API: http://localhost:8000/api/docs
```

### Deploy to GKE

```bash
# 0. Authenticate with GCP
gcloud auth login
gcloud auth application-default login

# 1. Bootstrap everything (GCP project + infra + cluster + ArgoCD)
#    You'll be prompted for your billing account ID
bash scripts/bootstrap.sh

# 2. Configure DNS (GoDaddy → Cloud DNS)
bash scripts/setup-dns.sh

# 3. Access cluster services
bash scripts/port-forward.sh
```

The bootstrap is fully IaC — even the GCP project itself is created by Terraform (`terraform/bootstrap/`). The flow:

1. **`terraform/bootstrap/`** — creates GCP project, enables APIs, creates state bucket (local state)
2. **`terraform/`** — creates VPC, GKE, DNS, IAM, Artifact Registry (remote state in GCS)
3. **`scripts/bootstrap.sh`** — installs ArgoCD, cert-manager, deploys app-of-apps

## Repository Structure

```
.
├── terraform/           # GKE, VPC, DNS, IAM, Artifact Registry
│   └── bootstrap/       # GCP project creation (IaC all the way down)
├── app/
│   ├── frontend/        # Hugo static site + Nginx
│   └── backend/         # Python FastAPI + SQLite
├── k8s/
│   ├── base/            # Kustomize base manifests
│   ├── overlays/        # dev / staging / production
│   └── argocd/          # App-of-apps GitOps definitions
├── monitoring/          # Prometheus + Grafana Helm values
├── extras/              # Deploy-on-demand showcases
│   ├── elasticsearch/   # EFK logging stack
│   ├── mysql/           # MySQL database
│   ├── jenkins/         # Jenkins CI + Jenkinsfile
│   └── istio/           # Service mesh config
├── scripts/             # Bash automation
├── .github/workflows/   # CI/CD pipelines
├── Makefile             # Developer UX
└── docker-compose.yaml  # Local development
```

## Make Targets

```bash
make help           # Show all targets
make dev            # Local Docker Compose
make build          # Build Docker images
make test           # Run tests + linting
make tf-plan        # Terraform plan
make bootstrap      # Full cluster setup
make teardown       # Destroy everything
```

---

Built by [Arian Svirsky](https://www.linkedin.com/in/ariansvirsky/) — DevOps Engineer since 2014.
