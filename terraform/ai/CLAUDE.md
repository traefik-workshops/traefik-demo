# Agent guide — `terraform/ai/`

Section-specific rules. Inherits everything from [`../../CLAUDE.md`](../../CLAUDE.md).

## Scope

Models, vector stores, and AI-adjacent tools. Anything that an LLM-powered demo would consume.

## Modules in this section

Live-derived; regenerate with `make discover | jq '.modules[] | select(.path | startswith("terraform/ai/"))'`.

| Module | Purpose |
|---|---|
| [`23ai/k8s`](./23ai/k8s) | Oracle Database 23ai (Free) StatefulSet + Service, optional Traefik ingress. |
| [`LLMs/runpod`](./LLMs/runpod) | LLM pods on RunPod (Llama 3.1 8B, GPT OSS 20B), gated by per-model `enable_*` flags. |
| [`NIMs/runpod`](./NIMs/runpod) | NVIDIA NIM safety microservices (Topic Control, Content Safety, Jailbreak) on RunPod. |
| [`ai-gateway-dependencies/k8s`](./ai-gateway-dependencies/k8s) | In-cluster dependencies the AI Gateway demo expects (Helm bundle). |
| [`granite-guardian/runpod`](./granite-guardian/runpod) | IBM Granite Guardian safety model pod on RunPod. |
| [`knative/k8s`](./knative/k8s) | Knative Serving install for the AI Gateway demo (Helm + CRDs). |
| [`milvus/k8s`](./milvus/k8s) | Milvus vector database via Helm. |
| [`ollama/k8s`](./ollama/k8s) | Ollama via Helm; optional pre-pulled model set (Qwen, DeepSeek, Llama). |
| [`open-webui/k8s`](./open-webui/k8s) | Open WebUI via Helm; optional Traefik ingress + OpenAI-compatible backends + MCP wiring. |
| [`presidio/k8s`](./presidio/k8s) | Microsoft Presidio (PII detection/anonymization) via raw Deployment+Service. |
| [`sqlcl/k8s`](./sqlcl/k8s) | SQLcl MCP server Deployment + Service, optional Traefik ingress. |
| [`weaviate/k8s`](./weaviate/k8s) | Weaviate vector database via Helm. |

## Sub-conventions

- **Platform subdir is mandatory** (`<module>/k8s/` or `<module>/runpod/`). Don't put `.tf` files directly under `terraform/ai/<module>/`.
- **k8s modules** are typically Helm-based — copy `milvus/k8s` or `weaviate/k8s` as the template.
- **RunPod modules** use the RunPod GraphQL API via `null_resource` + `curl`. Pattern lives in `LLMs/runpod` and `NIMs/runpod`.
- **Model variants** (different sizes/quantizations of the same model family) belong as `enable_<variant>` flags within a single module, not separate modules.

## What goes here vs nearby sections

- **AI gateway itself** → `terraform/traefik/` (the AI gateway is a Traefik feature)
- **AI gateway dependencies** (CRDs, namespaces it expects) → here, in `ai-gateway-dependencies/k8s`
- **AI observability** (Langfuse) → `terraform/observability/langfuse/k8s` (not here)
- **Generic ingress for AI services** → consumer's choice; this module doesn't ship one

## Required outputs

For model-serving modules (LLMs, NIMs, Ollama), expose:

- `endpoint` (string) — base URL the demo points its client at
- `pods` or equivalent identifier list (already done in RunPod modules)

For vector stores:

- `endpoint` (string) — service URL inside the cluster
- `port` (number) — typically 19530 (Milvus), 8080 (Weaviate)

If a module currently doesn't have these and you're touching it, add them (additive → `release-feature`).

## Don't

- Don't pull model weights into this repo. Refer to public images or HuggingFace IDs via variables.
- Don't pin model versions in defaults so tightly that a fresh demo gets a deprecated tag. Default to a known-good *channel* (e.g. `latest`) and let advanced users pin.
