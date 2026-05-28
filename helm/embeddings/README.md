# helm/embeddings

Lightweight embedding server using Infinity (michaelfeil/infinity)

- **Chart version:** `4.0.0` (slaved to the repo tag — see [`../AGENTS.md`](../AGENTS.md))
- **App version:** `0.0.75`

## Install

```bash
helm install my-embeddings oci://ghcr.io/traefik-workshops/embeddings --version 4.0.0
```

From source (for development against this repo):

```bash
cd helm/embeddings
helm dep update
helm install my-embeddings .
```

## Conventions

See [`../AGENTS.md`](../AGENTS.md) for chart conventions and [the root `AGENTS.md`](../../AGENTS.md) for repo-wide rules.

<!-- BEGIN_HELM_DOCS -->

## Requirements

| Name | Version |
|------|---------|
| kubernetes | (not pinned — pin in Chart.yaml) |
| helm | (apiVersion v2) |

## Values

| Key | Default |
|-----|---------|
| `image` | (object) |
| `image.repository` | `"michaelfeil/infinity"` |
| `image.tag` | `"0.0.75"` |
| `image.pullPolicy` | `"IfNotPresent"` |
| `model` | `"nomic-embed-text"` |
| `service` | (object) |
| `service.type` | `"ClusterIP"` |
| `service.port` | `7997` |
| `resources` | (object) |
| `resources.limits` | (object) |
| `resources.limits.cpu` | `"500m"` |
| `resources.limits.memory` | `"1Gi"` |
| `resources.requests` | (object) |
| `resources.requests.cpu` | `"100m"` |
| `resources.requests.memory` | `"256Mi"` |

<!-- END_HELM_DOCS -->
