# helm/hoppscotch

Self-hosted Hoppscotch with multi-collection nginx serving

- **Chart version:** `3.2.0` (slaved to the repo tag — see [`../CLAUDE.md`](../CLAUDE.md))
- **App version:** `2026.2.0`

## Install

```bash
helm install my-hoppscotch oci://ghcr.io/traefik-workshops/hoppscotch --version 3.2.0
```

From source (for development against this repo):

```bash
cd helm/hoppscotch
helm dep update
helm install my-hoppscotch .
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
| `global` | (object) |
| `global.domain` | `""` |
| `subdomain` | `"test"` |
| `host` | `""` |
| `image` | `"hoppscotch/hoppscotch:2026.2.0"` |
| `jwtSecret` | `"change-me-32-chars-long-exactly!"` |
| `sessionSecret` | `"change-me-32-chars-long-exactly!"` |
| `dataEncryptionKey` | `"change-me-32-chars-long-exactly!"` |
| `entryPoints` | (list, 1 items) |
| `collections` | `"[]"` |

<!-- END_HELM_DOCS -->
