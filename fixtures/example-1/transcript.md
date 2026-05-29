# Prospect Transcript — NexoVault Financial

**Format:** Email thread + follow-up call notes  
**SA:** Marcus Delacroix (marcus.delacroix@traefik.io)  
**Prospect contact:** Priya Shankar, Principal Platform Engineer, NexoVault Financial  

---

## Email thread

**From:** Priya Shankar <p.shankar@nexovault.io>  
**To:** marcus.delacroix@traefik.io  
**Date:** 2026-05-12  
**Subject:** Evaluating API gateway for our internal platform

Hi Marcus,

Thanks for reaching out at KubeCon. We're actively evaluating API gateway solutions for the next quarter and Traefik Hub caught our attention.

Quick background on us: NexoVault Financial is a B2B payments infrastructure company, ~800 engineers. We run everything on AWS. Our Kubernetes workloads are on EKS (us-east-1, two clusters — staging and prod) and we're fully in the AWS ecosystem including Cognito for user authentication.

Our core pain points right now:

1. **API management chaos** — we have 40+ internal microservices and no central gateway. Teams are exposing services ad-hoc with whatever ingress they feel like. We need a unified entry point with rate limiting, auth, and a developer portal so internal teams can discover and consume APIs without pinging us every time.
2. **Compliance pressure** — we just completed a SOC 2 Type II audit and the auditors flagged the lack of centralized API access logging. We need audit-grade request logs with traceability per service, per user.
3. **Developer experience** — our platform team is drowning in "can you give me access to X?" tickets. A self-serve API portal would reduce that by 80%.

Constraints worth knowing:
- We cannot use any GPU resources in the PoC environment due to our cloud spend policy this quarter.
- Must integrate with AWS Cognito — we're not willing to introduce another IdP.
- The security team wants observability built in — Grafana and Prometheus are our standard stack.

Are you available this week for a call? We'd like to see a PoC if possible before end of May.

Priya

---

**From:** Marcus Delacroix <marcus.delacroix@traefik.io>  
**To:** p.shankar@nexovault.io  
**Date:** 2026-05-13  
**Subject:** RE: Evaluating API gateway for our internal platform

Hi Priya,

This maps really well to what Traefik Hub is built for. All three pain points are addressable and I can have a PoC running for you on your actual AWS/EKS stack.

A few quick questions before I put together the environment:

1. Are you okay with deploying into a temporary EKS cluster for the PoC, or do you want us to demonstrate against one of your existing clusters?
2. Is there a specific set of APIs you'd like to expose in the portal — or should I use a representative set of sample services?
3. For Grafana, are you running Grafana + Prometheus already in the cluster or should I provision a full observability stack?

Let's sync Thursday at 2pm ET if that works.

Marcus

---

**From:** Priya Shankar <p.shankar@nexovault.io>  
**To:** marcus.delacroix@traefik.io  
**Date:** 2026-05-13  
**Subject:** RE: Evaluating API gateway for our internal platform

Thursday works.

To answer your questions:
1. A fresh EKS cluster is fine — we don't want vendor tooling in our prod clusters before we've decided.
2. Sample services are fine. We just need to see the portal experience and the auth flow.
3. We don't have Grafana/Prometheus in the PoC environment yet — please provision the full stack.

One more thing: our CISO will be on the call. He's going to ask about centralized audit logging for API calls. Please have that demoed — ideally with per-user traceability through Cognito JWT claims.

Priya

---

## Call notes — 2026-05-15 (Marcus Delacroix)

**Attendees:** Priya Shankar (Platform Eng), Derek Obi (CISO), two platform engineers from NexoVault

**Key takeaways:**

- Confirmed: fresh EKS cluster in us-east-1 is acceptable. They will not give us access to their VPC — we spin our own.
- Cognito user pool already exists; they'll give us the pool ID and client ID before the PoC.
- Derek specifically asked for: API-level access logs visible in Grafana, showing which Cognito user hit which endpoint and whether the call was allowed or rejected. This is non-negotiable for sign-off.
- The airlines demo format (portal + mock APIs + auth) was shown in the deck — Priya said "that's exactly the pattern we need."
- Timeline: decision by end of May. They have one other vendor (Kong) in the evaluation.
- No GPU, no external LLM services, no AI requirements for this PoC — they want pure API management and observability.
- Budget signal: they're okay with a ~$200/week AWS spend for the PoC environment.

**Modules to target:**
- EKS (fresh cluster, us-east-1)
- Traefik Hub on Kubernetes
- Cognito (use their existing pool)
- Airlines helm chart (portal + mock APIs)
- Grafana stack (metrics + logs)

**Open question:** Do they need cert-manager for TLS on the demo domain? Likely yes — will check during preflight.
