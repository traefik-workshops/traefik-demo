# helm/keycloak

Keycloak identity and access management with operator

- **Chart version:** `3.2.0` (slaved to the repo tag — see [`../CLAUDE.md`](../CLAUDE.md))
- **App version:** `26.5.2`

## Install

```bash
helm install my-keycloak oci://ghcr.io/traefik-workshops/keycloak --version 3.2.0
```

From source (for development against this repo):

```bash
cd helm/keycloak
helm dep update
helm install my-keycloak .
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
| `enabled` | `true` |
| `operatorVersion` | `"26.5.2"` |
| `namespace` | `"keycloak"` |
| `postgres` | (object) |
| `postgres.name` | `"keycloak-postgres"` |
| `postgres.database` | `"keycloak-db"` |
| `postgres.password` | `"topsecretpassword"` |
| `keycloak` | (object) |
| `keycloak.instances` | `1` |
| `keycloak.adminUser` | `"traefik"` |
| `keycloak.adminPassword` | `"topsecretpassword"` |
| `keycloak.httpEnabled` | `true` |
| `keycloak.hostnameStrict` | `false` |
| `keycloak.proxyHeaders` | `"xforwarded"` |
| `realm` | (object) |
| `realm.enabled` | `true` |
| `realm.name` | `"traefik"` |
| `realm.accessTokenLifespan` | `2419200` |
| `realm.users` | `"[]"` |
| `realm.extraUsers` | `"[]"` |
| `realm.advancedUsers` | `"[]"` |
| `realm.extraAdvancedUsers` | `"[]"` |
| `realm.clientSecret` | `"NoTgoLZpbrr5QvbNDIRIvmZOhe9wI0r0"` |
| `realm.redirectUris` | `"[]"` |
| `realm.extraRedirectUris` | `"[]"` |
| `validation` | (object) |
| `validation.image` | `"bitnami/kubectl:latest"` |
| `ingress` | (object) |
| `ingress.enabled` | `true` |
| `ingress.domain` | `"cloud"` |
| `ingress.entrypoint` | `"traefik"` |
| `ingress.observability` | `true` |
| `ingress.annotations` | `{}` |

<!-- END_HELM_DOCS -->
