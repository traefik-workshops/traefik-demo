# Agent guide — `terraform/ai/`

Section-specific rules. Inherits everything from [`../../CLAUDE.md`](../../CLAUDE.md).

## Scope

Models, vector stores, and AI-adjacent tools. Anything that an LLM-powered demo would consume.

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
