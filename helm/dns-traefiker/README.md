# helm/dns-traefiker

A Helm chart for the DNS Traefiker application

- **Chart version:** `3.2.0` (slaved to the repo tag — see [`../CLAUDE.md`](../CLAUDE.md))
- **App version:** `v1.0.2`

## Install

```bash
helm install my-dns-traefiker oci://ghcr.io/traefik-workshops/dns-traefiker --version 3.2.0
```

From source (for development against this repo):

```bash
cd helm/dns-traefiker
helm dep update
helm install my-dns-traefiker .
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
| `image.repository` | `"zalbiraw/dns-traefiker"` |
| `image.pullPolicy` | `"Always"` |
| `image.tag` | `"latest"` |
| `imagePullSecrets` | `"[]"` |
| `nameOverride` | `""` |
| `fullnameOverride` | `""` |
| `serviceAccount` | (object) |
| `serviceAccount.create` | `true` |
| `serviceAccount.annotations` | `{}` |
| `serviceAccount.name` | `""` |
| `podAnnotations` | `{}` |
| `podSecurityContext` | `{}` |
| `securityContext` | (object) |
| `securityContext.capabilities` | (object) |
| `securityContext.capabilities.drop` | (list, 1 items) |
| `securityContext.readOnlyRootFilesystem` | `true` |
| `securityContext.runAsNonRoot` | `true` |
| `securityContext.runAsUser` | `65532` |
| `secretName` | `"domain-secret"` |
| `traefikServiceName` | `"traefik"` |
| `traefikServiceNamespace` | `"traefik"` |
| `ipOverride` | `""` |
| `retryInterval` | `"30s"` |
| `maxRetries` | `5` |
| `proxied` | `true` |
| `uniqueDomain` | `false` |
| `domain` | `""` |
| `enableAirlinesSubdomain` | `false` |
| `resources` | (object) |
| `resources.limits` | (object) |
| `resources.limits.cpu` | `"100m"` |
| `resources.limits.memory` | `"128Mi"` |
| `resources.requests` | (object) |
| `resources.requests.cpu` | `"100m"` |
| `resources.requests.memory` | `"128Mi"` |
| `nodeSelector` | `{}` |
| `tolerations` | `"[]"` |
| `affinity` | `{}` |

<!-- END_HELM_DOCS -->
