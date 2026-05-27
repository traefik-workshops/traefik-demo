# helm/presidio

A Helm chart for Microsoft Presidio Analyzer

- **Chart version:** `3.2.0` (slaved to the repo tag — see [`../CLAUDE.md`](../CLAUDE.md))
- **App version:** `2.2.358`

## Install

```bash
helm install my-presidio oci://ghcr.io/traefik-workshops/presidio --version 3.2.0
```

From source (for development against this repo):

```bash
cd helm/presidio
helm dep update
helm install my-presidio .
```

## Conventions

See [`../CLAUDE.md`](./CLAUDE.md) for repo-wide rules and [`./CLAUDE.md`](./CLAUDE.md) for chart-specific conventions.

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
| `image.repository` | `"mcr.microsoft.com/presidio-analyzer"` |
| `image.tag` | `"2.2.358"` |
| `image.pullPolicy` | `"IfNotPresent"` |
| `service` | (object) |
| `service.type` | `"ClusterIP"` |
| `service.port` | `3000` |
| `resources` | (object) |
| `resources.limits` | (object) |
| `resources.limits.cpu` | `"1"` |
| `resources.limits.memory` | `"2Gi"` |
| `resources.requests` | (object) |
| `resources.requests.cpu` | `"200m"` |
| `resources.requests.memory` | `"1Gi"` |

<!-- END_HELM_DOCS -->
