# Prospect Transcript — Cartify Commerce

**Format:** Slack export + follow-up email (internal SA notes appended)  
**SA:** Jerome Okafor (jerome.okafor@traefik.io)  
**Prospect contacts:**  
- Leila Nakashima, Head of Platform Engineering, Cartify Commerce  
- Femi Adeyemi, Staff AI Engineer  

---

## Slack DMs — #traefik-evaluation (exported 2026-05-20)

**Leila Nakashima [10:02]**  
Hey Jerome, following up from the webinar last week. We're at Cartify — mid-size e-commerce platform, ~150M GMV/year, fully on GCP. We run on GKE. Our AI team has been building a bunch of internal agents over the past 6 months and we have a real problem: every agent is calling APIs differently, there's no governance, no rate limiting, no visibility into which agent is hitting what.

**Jerome Okafor [10:15]**  
That's a classic MCP gateway use case. Are your agents using MCP protocol, or raw REST?

**Leila Nakashima [10:18]**  
Mix of both right now. Femi can give you more detail — he built most of them. But the plan is to standardize on MCP going forward.

**Femi Adeyemi [10:24]**  
Yeah so here's our setup: we have 5 internal tools exposed as services — inventory lookup, pricing engine, customer support history, logistics tracker, and a returns processor. We want to expose all of them as MCP tools so our agents can call them. Right now each agent has hardcoded credentials to each service. It's a mess.

We want a central MCP gateway that:
1. Routes agent calls to the right backend tool
2. Enforces which agent can call which tool (authz)
3. Rate limits by agent identity
4. Gives us a log of every tool call for debugging

**Jerome Okafor [10:35]**  
Traefik Hub's MCP gateway does exactly that. Are your agents running inside the cluster, or are they external callers?

**Femi Adeyemi [10:38]**  
Inside the cluster. We run them on GKE. We use Keycloak for internal auth — we have a realm set up already with agent identities as service accounts.

**Leila Nakashima [10:41]**  
We also want something the AI team can use to test and inspect MCP calls without building a custom tool every time. Like a debugger.

**Jerome Okafor [10:44]**  
There's an MCP inspector module we can deploy alongside — it's a UI for inspecting live MCP traffic. Would cover that use case.

**Leila Nakashima [10:46]**  
Perfect. Can we also have some sample backend services in the PoC? Our actual services aren't available in a sandbox.

**Jerome Okafor [10:48]**  
Yes — we can spin up httpbin and whoami as stand-ins for your backend tools. They're good enough for demonstrating routing and auth.

**Femi Adeyemi [10:52]**  
One more thing — we're starting to build RAG agents that need a vector store. Nothing for the PoC necessarily, but if you could show Milvus or something similar deployed alongside, that would help us plan the next phase.

**Jerome Okafor [11:00]**  
We can include Milvus as an optional layer. It won't be connected to the MCP gateway in the PoC but it'll show you the deployment pattern.

**Leila Nakashima [11:03]**  
Timeline: we want to see this by end of month. We have a board presentation June 3rd where we want to show "this is how we're going to govern AI in our stack."

---

## Follow-up email — 2026-05-20

**From:** Leila Nakashima <l.nakashima@cartify.io>  
**To:** jerome.okafor@traefik.io  
**Subject:** PoC requirements summary — Cartify MCP Gateway

Hi Jerome,

Quick summary of what we discussed:

**Hard requirements:**
- GKE cluster (GCP, us-central1)
- Traefik Hub as MCP gateway — central routing for all internal AI tool calls
- Keycloak integration — we have our realm config ready, can export it to you
- Per-agent authorization and rate limiting
- MCP inspector for the AI team to debug tool calls
- Sample backend services (httpbin / whoami are fine)

**Nice to have:**
- Milvus vector DB deployment (future RAG use case, no connection to MCP gateway needed)
- Basic observability (we use Grafana internally, so Prometheus + Grafana would be ideal)

**Constraints:**
- GCP only — we have committed spend there
- No external LLM required for this PoC — it's purely about gateway/routing, not model serving
- Keycloak is our IdP — we don't want to add another SSO system

**Not in scope:**
- Any model serving (Ollama, RunPod, etc.) — AI agents call external LLM APIs directly; we just want the MCP layer
- Any AWS or Azure services

Looking forward to seeing this built. Let me know if you need the GCP project ID or service account.

Leila

---

## SA notes (Jerome Okafor, 2026-05-20)

- Cloud: GCP / GKE, us-central1
- Auth: Keycloak (existing realm, they'll export config) — use helm/keycloak chart or terraform/security/keycloak/k8s
- Gateway: Traefik Hub k8s with MCP gateway mode + ai-gateway-dependencies CRDs
- Inspector: terraform/tools/mcp-inspector/k8s — explicitly requested
- Backend stubs: terraform/apps/httpbin/k8s + terraform/apps/whoami/k8s
- Vector DB: terraform/ai/milvus/k8s — nice to have, no integration needed, just show the module
- Observability: terraform/observability/grafana-stack/k8s — nice to have, include if time allows
- No AI/LLM serving — agents call external APIs, we just manage the MCP layer
- No GPU, no RunPod, no Ollama
- Decision timeline: demo by 2026-05-30, board presentation 2026-06-03
- Potential gap: Keycloak realm import — they have an existing realm config; check if our helm/keycloak chart supports importing a pre-existing realm export
