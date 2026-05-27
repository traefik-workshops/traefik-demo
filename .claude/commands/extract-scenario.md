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

Before mapping, ground yourself in the current module set:

- Run `find terraform -name versions.tf -not -path '*/.terraform/*' | xargs dirname | sort` (TF) and `find helm -name Chart.yaml -maxdepth 2 | xargs dirname | sort` (Helm) to list every leaf module that actually exists.
- Skim [`/CLAUDE.md`](../../CLAUDE.md) for section ownership rules — what belongs in `terraform/ai/` vs `terraform/tools/` vs `terraform/traefik/` etc.

Then map every technical signal in the prospect input to a module that you have confirmed exists. The table below is a starting heuristic — verify each match by reading the module's `variables.tf`:

| Signal in text | Module |
|---|---|
| "AWS", "EKS", "Amazon" | terraform/compute/aws/eks + terraform/compute/aws/vpc |
| "Azure", "AKS", "Microsoft" | terraform/compute/azure/aks |
| "GCP", "GKE", "Google Cloud" | terraform/compute/gcp/gke |
| "on-prem", "no cloud", "local" | terraform/compute/suse/k3d |
| "Nutanix", "NKP" | terraform/compute/nutanix/nkp |
| (always) | terraform/traefik/shared — include in every PoC |
| "AI", "LLM", "chatbot", "copilot" | terraform/ai/ollama/k8s (CPU) or terraform/ai/LLMs/runpod (GPU) |
| "AI gateway", "MCP", "model routing" | terraform/ai/ai-gateway-dependencies/k8s |
| "vector search", "RAG", "embeddings" | terraform/ai/milvus/k8s or terraform/ai/weaviate/k8s |
| "SSO", "OIDC", "Azure AD", "EntraID" | terraform/security/entraid |
| "SSO", "OIDC", "Cognito" | terraform/security/cognito |
| "SSO", "OIDC", "Keycloak", "generic" | terraform/security/keycloak/k8s |
| "monitoring", "observability", "Grafana" | terraform/observability/grafana-stack/k8s |
| "tracing", "OpenTelemetry" | terraform/observability/opentelemetry/k8s + terraform/observability/grafana-tempo/k8s |
| "AI observability", "LLM tracing" | terraform/observability/langfuse/k8s |
| "database", "PostgreSQL" | terraform/tools/postgresql/k8s |
| "cache", "Redis" | terraform/tools/redis/k8s |
| "DNS", "Cloudflare" | terraform/tools/cloudflare |
| "load test", "k6" | terraform/tools/k6-operator/k8s |
| "GitOps", "ArgoCD" | terraform/tools/argocd/k8s |
| "data masking", "PII", "Presidio" | terraform/ai/presidio/k8s |
| "demo app", "sample app" | terraform/apps/whoami/k8s or terraform/apps/httpbin/k8s |
| "Traefik AI gateway", "AI middleware", "PII guard", "topic control", "content safety" | helm/ai-gateway |
| "airlines demo", "full demo", "scalar mock", "API management demo" | helm/airlines (umbrella — pulls keycloak + hoppscotch + ai-gateway as subcharts) |
| "API testing UI", "Hoppscotch", "Postman alternative" | helm/hoppscotch |
| "self-hosted Keycloak", "in-cluster IdP", "OIDC realm with seeded users" | helm/keycloak |
| "PII detection backend", "Presidio analyzer" | helm/presidio |
| "embedding server", "RAG embeddings", "Infinity", "nomic-embed" | helm/embeddings |
| "wildcard DNS for demos", "*.demo.X domain", "Cloudflare auto record" | helm/dns-traefiker |

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
  ✅ terraform/compute/<path>        — <reason from text>
  ✅ terraform/traefik/shared        — always included
  ✅ terraform/security/<path>       — <reason from text>
  ✅ <module>              — <reason from text>

Gaps (not covered by available modules):
  ⚠️  <requirement>       — <explanation>

Questions before building:
  1. <question if critical info missing>
```

## Rules

- Never invent a cloud provider — if not mentioned, ask SA before defaulting
- Always include `terraform/traefik/shared` — it's the point of every demo
- If transcript mentions multiple clouds, pick the one with strongest signal and flag ambiguity
- If no AI components mentioned, do not add AI modules — match what was asked
- Keep gaps list honest — do not map requirements to modules that don't fit