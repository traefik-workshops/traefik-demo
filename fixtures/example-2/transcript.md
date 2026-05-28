# Prospect Transcript — MedPilot Health

**Format:** Discovery call transcript (condensed)  
**SA:** Sonja Brandt (sonja.brandt@traefik.io)  
**Prospect contacts:**  
- Tobias Keller, VP Engineering, MedPilot Health  
- Anastasia Voronova, Security & Compliance Lead  

---

## Discovery call transcript — 2026-05-19

**Sonja:** Thanks for joining, Tobias, Anastasia. Can you walk me through what you're trying to build?

**Tobias:** Sure. MedPilot is a clinical decision support platform. We're a 200-person company, Azure-native — all our workloads run on AKS. We use EntraID for everything, SSO across the board.

We want to build an internal AI assistant for our clinical staff — think: a chat interface where nurses and clinicians can ask questions about patient protocols, drug interactions, that kind of thing. The LLM would be running locally inside our cluster, not calling out to OpenAI or any external API, because of HIPAA.

**Sonja:** Understood. What's the current state — do you have a model running?

**Tobias:** Not yet. We've been testing with Ollama locally on developer laptops. We want to run it in the cluster. We don't have GPU nodes — our Azure subscription doesn't have GPU quota right now and procurement is slow. So it would need to run on CPU, at least for the PoC. We're thinking a small model, 7B or 8B range.

**Anastasia:** Can I jump in? The compliance piece is critical for us. We're HIPAA-regulated. The model will see queries that might contain patient identifiers — names, MRNs, dates. We need to make sure that if someone accidentally pastes a patient record into the chat, that PII gets detected and masked before it ever hits the model or logs.

**Sonja:** That's a great signal. We have a PII detection and masking layer built around Microsoft Presidio that sits in front of the LLM. It detects and anonymizes before the request reaches the model. Let me ask — do you need the original response to be re-identified after the model responds, or just masked end-to-end?

**Anastasia:** Masked end-to-end is fine for the PoC. As long as the model never sees raw PII, we're satisfied for the compliance sign-off.

**Tobias:** We also want to see how requests get routed through Traefik. The AI assistant is one use case, but we'll eventually have other internal tools — an admin portal, some internal APIs. We'd want one gateway managing it all.

**Sonja:** So the arc is: AKS cluster, EntraID SSO securing the chat UI, Traefik Hub as the central gateway, Ollama running a CPU model, Presidio in front for PII scrubbing, and a chat front-end for clinical staff to interact with the model.

**Tobias:** Exactly. And if you can add some observability — we use Azure Monitor but we're open to Grafana in the PoC — that would help us show the security team what's going where.

**Sonja:** Grafana stack with LLM request tracing via Langfuse would cover that. You'd be able to see every model call, latency, and which user triggered it through the EntraID token.

**Anastasia:** What model would you use for the CPU-only PoC?

**Sonja:** Ollama defaults to llama3.2 or similar 8B model — runs on CPU without issues, just slower inference. For a PoC this is fine. If you want a production-grade GPU setup later, we have a different path for that.

**Tobias:** That works. What do you need from us to get started?

**Sonja:** I'll need your Azure subscription ID and AKS region preference. And we'll need your EntraID tenant ID and a client ID/secret for the OIDC integration. Can your team provide those?

**Tobias:** Anastasia, can we get those to Sonja by Wednesday?

**Anastasia:** Yes, I'll send them over. One constraint: we cannot have any data leave our Azure region — westeurope. The PoC needs to stay fully within EU boundaries.

**Sonja:** Noted. AKS in westeurope, all services in-cluster. No external API calls from the model.

**Tobias:** Timeline: we have an internal steering committee review on June 10th. We need the PoC ready and demoed by June 5th.

**Sonja:** That's tight but doable. Let me get started this week.

---

## SA follow-up notes (Sonja Brandt, 2026-05-19)

- Cloud: Azure / AKS, region westeurope (hard constraint — EU data residency)
- Auth: EntraID — tenant ID and client credentials incoming from Anastasia by 2026-05-21
- LLM: CPU-only, Ollama k8s module, 8B model (no GPU quota available)
- PII layer: Presidio k8s module — masks before model sees request
- UI: Open WebUI or similar chat front-end
- Gateway: Traefik Hub on k8s with EntraID OIDC
- Observability: Grafana stack + Langfuse for LLM tracing
- Compliance constraint: HIPAA, data masking is required before model, no external API calls
- Decision timeline: demo needed by 2026-06-05, steering committee 2026-06-10
- No GPU, no vector DB needed for this PoC (no RAG requirement mentioned)
- Potential gap: no EntraID Terraform module in repo — may need to use Keycloak as proxy IdP or configure EntraID manually and document it
