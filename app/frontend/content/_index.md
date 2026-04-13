---
title: "Home"
---

![Arian Svirsky](/images/arian.png)

# Arian Svirsky

Staff Infrastructure / DevOps Engineer — I own production platforms that handle millions of requests a day, across multiple clouds, without waking people up.

**Core stack:** Kubernetes · AWS · GCP · Terraform · Pulumi · Datadog · Serverless · CI/CD · Observability · Networking

---

10+ years shipping and running production infrastructure. I work where reliability, performance, and cost all have to land at the same time — multi-region Kubernetes, multi-cloud, high-scale systems where a 30-second outage is a postmortem and a 500ms tail latency is a ticket.

At [Descope](https://www.descope.com) I'm on the platform team behind the identity product — **25+ microservices running on AWS and GCP, deployed to 4 regions, serving millions of authentication requests a day**. I own reliability on the services I'm responsible for, drive observability across the fleet (Datadog APM, SLOs, on-call runbooks), and ship infrastructure through a fully automated Pulumi + RC promotion pipeline. When something degrades in Singapore at 3am, I'm the one who knows why.

Before that, 6 years at [Palo Alto Networks](https://www.paloaltonetworks.com) (Cortex XSOAR, formerly Demisto), leaving as **Principal DevOps Engineer**. I led the migration of the product from EC2 to Kubernetes — including the genuinely hard problem of running Docker-in-Docker securely inside a security product that executes untrusted customer code. Owned the CI/CD architecture, AWS cost and security posture, and the observability transformation from Nagios to Prometheus + Grafana.

Since 2014. I like infrastructure problems that don't have Stack Overflow answers — the kind where you own the decision, the design, and the 3am page if it breaks.

---

This site is its own DevOps project — rebuilt on [Cloud Run](https://cloud.google.com/run) + [Firestore](https://cloud.google.com/firestore) after I killed the original GKE + ArgoCD + Prometheus stack. **Same functionality, ~96% cheaper (\$120/mo → \$5/mo)** — the same cost/complexity tradeoff I make at work, on a small enough project to ship it in a weekend. [Terraform](https://github.com/ariansvi/ariansvi-resume-v2/tree/main/terraform) for every resource, [GitHub Actions](https://github.com/ariansvi/ariansvi-resume-v2/actions) with Workload Identity Federation (no long-lived keys). The archived GKE build is on the [`archive/gke-stack`](https://github.com/ariansvi/ariansvi-resume-v2/tree/archive/gke-stack) branch. [Source](https://github.com/ariansvi/ariansvi-resume-v2).
