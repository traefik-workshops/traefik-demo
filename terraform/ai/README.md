# ai/

Modules for the AI side of a demo: model serving, vector stores, AI gateway dependencies, and a few model-adjacent tools.

Most modules here run on **Kubernetes** (`<module>/k8s/`). A few run on **RunPod** (`<module>/runpod/`) when GPUs are cheaper there than in your hyperscaler. Every k8s module assumes a working cluster — provision one from `terraform/compute/` first.

## Modules

| Path | Platform | Purpose |
|---|---|---|
| [`23ai/k8s`](./23ai/k8s) | k8s | Oracle 23ai database (vector + RDBMS) |
| [`LLMs/runpod`](./LLMs/runpod) | RunPod | LLM endpoints (Llama 3.1 8B, GPT-OSS 20B, ...) |
| [`NIMs/runpod`](./NIMs/runpod) | RunPod | NVIDIA NIM endpoints (needs NGC credentials) |
| [`ai-gateway-dependencies/k8s`](./ai-gateway-dependencies/k8s) | k8s | Cluster prereqs for the AI gateway demo (CRDs, namespaces) |
| [`granite-guardian/runpod`](./granite-guardian/runpod) | RunPod | IBM Granite Guardian (safety classifier) |
| [`knative/k8s`](./knative/k8s) | k8s | Knative Serving for scale-to-zero model endpoints |
| [`milvus/k8s`](./milvus/k8s) | k8s | Milvus vector DB |
| [`ollama/k8s`](./ollama/k8s) | k8s | Ollama for local-style LLM serving (multiple models via flags) |
| [`open-webui/k8s`](./open-webui/k8s) | k8s | Open WebUI frontend, points at the AI gateway or Ollama |
| [`presidio/k8s`](./presidio/k8s) | k8s | Microsoft Presidio (PII analyzer/anonymizer) |
| [`sqlcl/k8s`](./sqlcl/k8s) | k8s | Oracle SQLcl pod for hands-on demos |
| [`weaviate/k8s`](./weaviate/k8s) | k8s | Weaviate vector DB |

## Common prerequisites

- **k8s modules:** a configured cluster (see `terraform/compute/`), the `helm`/`kubernetes` providers pointed at it.
- **RunPod modules:** a `runpod_api_key`. For NIMs you also need `ngc_token` + `ngc_username`.

## When to add a new model

If you're adding **another Ollama model**, prefer adding an `enable_<model>` flag to the existing `ollama/k8s` module rather than creating a new module. New modules are for new *systems*, not new SKUs.

If you're adding a new vector store (Qdrant, pgvector, etc.), follow the `milvus/k8s` / `weaviate/k8s` pattern.

## Section-specific conventions

See [`./CLAUDE.md`](./CLAUDE.md).
