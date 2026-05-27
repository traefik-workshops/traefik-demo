# demos/ai-gateway

AI gateway demo with the smallest viable model footprint. CPU-only — no GPU needed. Adds Keycloak so the AI gateway can demonstrate per-user routing.

## What it proves

- Traefik Hub AI gateway features install correctly.
- An in-cluster model (Ollama) can be hit through the AI gateway with shared middlewares applied (PII guard via Presidio, semantic cache via Embeddings+Weaviate).
- OIDC auth works via Keycloak.

## Install — two-phase

### Phase 1: Terraform (cluster + Traefik + Keycloak + Ollama)

```bash
cp terraform.tfvars.example terraform.tfvars
# edit terraform.tfvars
terraform init
terraform apply
```

### Phase 2: Helm (AI gateway umbrella chart)

The AI gateway chart pulls Presidio + Embeddings + Weaviate as subcharts:

```bash
export KUBECONFIG=$(terraform output -raw kubeconfig)
helm install ai-gateway oci://ghcr.io/traefik-workshops/ai-gateway --version 4.0.0 \
  --namespace ai --create-namespace \
  --set domain=$(terraform output -raw domain) \
  --set apiKeys.openai=$OPENAI_API_KEY \
  --set sharedMiddlewares.semanticCache.enabled=true
```

See the [`helm/ai-gateway`](../../helm/ai-gateway/README.md) chart for the full values reference.

## Extending

- **GPU model backend** — swap Ollama for `terraform/ai/LLMs/runpod` (GPU on RunPod, costs $$).
- **More users** — add to `realm.advancedUsers` in the keycloak module.
- **No auth** — drop the keycloak module + namespace.
- **More guardrails** — turn on `topicControl`, `contentSafety`, `jailbreakDetection` in the chart values.

## Sourced from

Shape extracted from the `ai-demo` repo. **All credentials in that repo are committed in plaintext** — this archetype puts them through `variables.tf` instead.
