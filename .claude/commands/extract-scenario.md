# Extract Scenario

Read unstructured prospect input and produce a structured scenario ready for `/build-poc`.

## Invocation

```
/extract-scenario <path-to-file>
```

The file can be any plain text format: `.md`, `.txt`, `.pdf` (text-based), email export, transcript export.

Read the file at the given path before proceeding. If the file does not exist or is unreadable, report the error and stop.

## Step 1 — Extract prospect context

| Field | What to look for |
|---|---|
| Prospect name | Company name, domain, sender org |
| Industry | Financial services, healthcare, retail, public sector, etc. |
| Current infra | Cloud provider mentioned, existing Kubernetes, on-prem |
| Pain points | What problem they're trying to solve |
| Constraints | Compliance (GDPR, HIPAA), air-gap, no GPU, budget signals |
| Timeline | Demo urgency — "next week", "end of quarter" |
| Key stakeholders | DevOps, platform team, CISO, etc. |

## Step 2 — Map to modules

Read MODULE_CATALOG.md, then map every technical signal:

| Signal in text | Module |
|---|---|
| "AWS", "EKS", "Amazon" | compute/aws/eks + compute/aws/vpc |
| "Azure", "AKS", "Microsoft" | compute/azure/aks |
| "GCP", "GKE", "Google Cloud" | compute/gcp/gke |
| "on-prem", "no cloud", "local" | compute/suse/k3d |
| "Nutanix", "NKP" | compute/nutanix/nkp |
| (always) | traefik/shared — include in every PoC |
| "AI", "LLM", "chatbot", "copilot" | ai/ollama/k8s (CPU) or ai/LLMs/runpod (GPU) |
| "AI gateway", "MCP", "model routing" | ai/ai-gateway-dependencies/k8s |
| "vector search", "RAG", "embeddings" | ai/milvus/k8s or ai/weaviate/k8s |
| "SSO", "OIDC", "Azure AD", "EntraID" | security/entraid |
| "SSO", "OIDC", "Cognito" | security/cognito |
| "SSO", "OIDC", "Keycloak", "generic" | security/keycloak/k8s |
| "monitoring", "observability", "Grafana" | observability/grafana-stack/k8s |
| "tracing", "OpenTelemetry" | observability/opentelemetry/k8s + grafana-tempo/k8s |
| "AI observability", "LLM tracing" | observability/langfuse/k8s |
| "database", "PostgreSQL" | tools/postgresql/k8s |
| "cache", "Redis" | tools/redis/k8s |
| "DNS", "Cloudflare" | tools/cloudflare |
| "load test", "k6" | tools/k6-operator/k8s |
| "GitOps", "ArgoCD" | tools/argocd/k8s |
| "data masking", "PII", "Presidio" | ai/presidio/k8s |
| "demo app", "sample app" | apps/whoami/k8s or apps/httpbin/k8s |

## Step 3 — Identify gaps

Flag anything with NO matching module:
- List each gap explicitly
- Suggest closest alternative if one exists
- Mark as "out of scope for this PoC" if nothing applies

## Step 4 — Output

### A. Scenario summary

```
Prospect:    <name>
Industry:    <industry>
Cloud:       <provider>
Constraints: <list or "none identified">
Timeline:    <urgency or "not mentioned">

Modules selected:
  ✅ compute/<path>        — <reason from text>
  ✅ traefik/shared        — always included
  ✅ security/<path>       — <reason from text>
  ✅ <module>              — <reason from text>

Gaps (not covered by available modules):
  ⚠️  <requirement>       — <explanation>

Questions before building:
  1. <question if critical info missing>
```

## Rules

- Never invent a cloud provider — if not mentioned, ask SA before defaulting
- Always include `traefik/shared` — it's the point of every demo
- If transcript mentions multiple clouds, pick the one with strongest signal and flag ambiguity
- If no AI components mentioned, do not add AI modules — match what was asked
- Keep gaps list honest — do not map requirements to modules that don't fit
