# ariansvi.com — DevOps Resume as Code

A personal resume website that **is itself** a DevOps showcase. Every layer of the stack — from infrastructure provisioning to CI/CD — demonstrates real-world engineering practices, tuned to cost ~$5/month instead of $120/month.

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
                    │    Cloud Run          │
                    │    (Terraform)        │
                    ├───────────────────────┤
                    │  ┌─────────────────┐  │
                    │  │  Domain mapping │  │
                    │  │  (managed TLS)  │  │
                    │  └───┬─────────┬───┘  │
                    │      │         │      │
                    │  ┌───▼───┐ ┌───▼───┐  │
                    │  │Frontend│ │Backend│  │
                    │  │Hugo +  │ │FastAPI│  │
                    │  │ Nginx  │ │       │  │
                    │  └────────┘ └───┬───┘  │
                    └─────────────────┼─────┘
                                      ▼
                              ┌──────────────┐
                              │  Firestore   │
                              │  (analytics) │
                              └──────────────┘
```

**Previous version:** a GKE Autopilot + ArgoCD + ingress-nginx + cert-manager + Prometheus + Grafana build is preserved on the [`archive/gke-stack`](https://github.com/ariansvi/ariansvi-resume-v2/tree/archive/gke-stack) branch.

## Skills Demonstrated

| Category | Technologies |
|----------|-------------|
| **Serverless compute** | Cloud Run v2 (scale-to-zero, managed TLS, domain mapping) |
| **Infrastructure as Code** | Terraform (modules, remote state, Workload Identity) |
| **CI/CD** | GitHub Actions, Workload Identity Federation (no long-lived keys) |
| **Containers** | Docker (multi-stage, Alpine, runtime config via envsubst) |
| **Backend** | Python FastAPI, Firestore |
| **Networking** | Cloud Run domain mapping, Cloud DNS, HTTPS |
| **Security** | Non-root containers, CSP/HSTS, IP masking in analytics |
| **(Previous GKE stack)** | Kubernetes, Helm, Kustomize, ArgoCD, Prometheus, cert-manager |

## Quick Start

### Local Development

```bash
# Start everything with Docker Compose
make dev

# Frontend: http://localhost:8080
# Backend API: http://localhost:8000/api/health
```

The backend needs Firestore. For local dev without GCP, you can run the [Firestore emulator](https://cloud.google.com/firestore/docs/emulator) and set `FIRESTORE_EMULATOR_HOST` — or just skip analytics locally.

### Deploy to Cloud Run

```bash
# 0. Authenticate with GCP
gcloud auth login
gcloud auth application-default login

# 1. Create the GCP project (one-time)
cd terraform/bootstrap && terraform init && terraform apply

# 2. Provision all infra (Cloud Run, Firestore, Artifact Registry, DNS, IAM)
cd ../ && terraform init && terraform apply

# 3. Point GoDaddy nameservers to Cloud DNS
bash scripts/setup-dns.sh
```

After that, every push to `main` that touches `app/**` builds new images and redeploys both Cloud Run services automatically via GitHub Actions.

## Repository Structure

```
.
├── terraform/           # Cloud Run, Firestore, DNS, IAM, Artifact Registry
│   └── bootstrap/       # GCP project creation
├── app/
│   ├── frontend/        # Hugo + Nginx (templated nginx.conf for Cloud Run)
│   └── backend/         # Python FastAPI + Firestore
├── scripts/             # DNS setup helpers
├── .github/workflows/   # CI + build-push-deploy pipelines
├── Makefile             # Developer UX
└── docker-compose.yaml  # Local dev
```

## Make Targets

```bash
make help           # Show all targets
make dev            # Local Docker Compose
make build          # Build Docker images
make push           # Push to Artifact Registry
make deploy         # Deploy current tag to Cloud Run
make test           # Run tests + linting
make tf-plan        # Terraform plan
make tf-apply       # Terraform apply
```

---

Built by [Arian Svirsky](https://www.linkedin.com/in/ariansvirsky/) — DevOps Engineer since 2014.
