---
title: "Home"
---

![Arian Svirsky](/images/arian.jpg)

# Arian Svirsky

Staff-level Infrastructure Engineer — I build the platforms product teams deploy on.

**Core stack:** Kubernetes · AWS · GCP · Terraform · Pulumi · Datadog · Serverless · CI/CD · Observability · Networking

---

10+ years in production infrastructure. Multi-region Kubernetes, multi-cloud, high-scale systems — the kind of environments where a 30-second outage is a postmortem and a 500ms tail latency is a ticket.

At [Descope](https://www.descope.com) I'm part of the platform team behind the identity product — a 25+ microservice system running across AWS and GCP, deployed to 4 regions, serving millions of authentication requests a day. I own reliability on services I'm responsible for, drive observability across the fleet (Datadog APM, SLOs, on-call runbooks), and ship infrastructure changes through a fully automated Pulumi + RC promotion pipeline. When something degrades in Singapore at 3am, I'm the one who knows why.

Before that I spent 6 years at [Palo Alto Networks](https://www.paloaltonetworks.com) (Cortex XSOAR, formerly Demisto), leaving as **Principal DevOps Engineer**. I led the migration of the product from EC2 to Kubernetes — including the non-trivial problem of running Docker-in-Docker securely inside a security product that executes untrusted customer code. Also owned the CI/CD architecture, AWS posture, and the observability transformation from Nagios to Prometheus + Grafana.

Since 2014. I like infrastructure problems that don't have Stack Overflow answers — the kind where you own the decision, the design, and the 3am page if it breaks.

---

This site is its own DevOps project — [Cloud Run](https://cloud.google.com/run) (serverless, scales to zero), [Firestore](https://cloud.google.com/firestore) for analytics, [Terraform](https://github.com/ariansvi/ariansvi-resume-v2/tree/main/terraform) for every resource, [GitHub Actions](https://github.com/ariansvi/ariansvi-resume-v2/actions) with Workload Identity Federation (no long-lived keys). Runs for ~$5/month. The original GKE + ArgoCD + Prometheus build is archived on the [`archive/gke-stack`](https://github.com/ariansvi/ariansvi-resume-v2/tree/archive/gke-stack) branch. [Source](https://github.com/ariansvi/ariansvi-resume-v2).
