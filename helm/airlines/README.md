# helm/airlines

Airlines Demo - Scalar Mock Server APIs with Traefik Hub API Management

- **Chart version:** `4.0.0` (slaved to the repo tag — see [`../AGENTS.md`](../AGENTS.md))
- **App version:** `2.0.0`

## Install

```bash
helm install my-airlines oci://ghcr.io/traefik-workshops/airlines --version 4.0.0
```

From source (for development against this repo):

```bash
cd helm/airlines
helm dep update
helm install my-airlines .
```

## Conventions

See [`../AGENTS.md`](../AGENTS.md) for chart conventions and [the root `AGENTS.md`](../../AGENTS.md) for repo-wide rules.

<!-- BEGIN_HELM_DOCS -->

## Requirements

| Name | Version |
|------|---------|
| kubernetes | (not pinned — pin in Chart.yaml) |
| helm | (apiVersion v2) |

## Dependencies

| Name | Version | Repository | Condition |
|------|---------|------------|-----------|
| keycloak | `4.0.0` | `file://../keycloak` | `keycloak.enabled` |
| hoppscotch | `4.0.0` | `file://../hoppscotch` | `hoppscotch.enabled` |
| ai-gateway | `4.0.0` | `file://../ai-gateway` | `aiGateway.enabled` |

## Values

| Key | Default |
|-----|---------|
| `entryPoints` | (list, 1 items) |
| `global` | (object) |
| `global.domain` | `"demo.traefik.ai"` |
| `global.multicluster` | (object) |
| `global.multicluster.enabled` | `false` |
| `global.multicluster.mode` | `"parent"` |
| `global.multicluster.parent` | (object) |
| `global.multicluster.parent.groups` | (object) |
| `global.multicluster.parent.groups.flightOps` | `""` |
| `global.multicluster.parent.groups.flightOpsMcp` | `""` |
| `global.multicluster.parent.groups.passengerSvc` | `""` |
| `global.multicluster.parent.groups.passengerSvcMcp` | `""` |
| `global.multicluster.parent.groups.airportOps` | `""` |
| `global.multicluster.parent.groups.airportOpsMcp` | `""` |
| `global.multicluster.parent.groups.aiGateway` | `""` |
| `global.multicluster.child` | (object) |
| `global.multicluster.child.uplinkEntryPoints` | (object) |
| `global.multicluster.child.uplinkEntryPoints.flightOps` | `"flight-ops"` |
| `global.multicluster.child.uplinkEntryPoints.flightOpsMcp` | `"flight-ops-mcp"` |
| `global.multicluster.child.uplinkEntryPoints.passengerSvc` | `"passenger-svc"` |
| `global.multicluster.child.uplinkEntryPoints.passengerSvcMcp` | `"passenger-svc-mcp"` |
| `global.multicluster.child.uplinkEntryPoints.airportOps` | `"airport-ops"` |
| `global.multicluster.child.uplinkEntryPoints.airportOpsMcp` | `"airport-ops-mcp"` |
| `global.multicluster.child.uplinkEntryPoints.aiGateway` | `"ai-gateway"` |
| `global.multicluster.child.groups` | (object) |
| `global.multicluster.child.groups.flightOps` | `false` |
| `global.multicluster.child.groups.flightOpsMcp` | `false` |
| `global.multicluster.child.groups.passengerSvc` | `false` |
| `global.multicluster.child.groups.passengerSvcMcp` | `false` |
| `global.multicluster.child.groups.airportOps` | `false` |
| `global.multicluster.child.groups.airportOpsMcp` | `false` |
| `global.multicluster.child.groups.aiGateway` | `false` |
| `global.multicluster.child.mcp` | (object) |
| `global.multicluster.child.mcp.base` | `"http://traefik.traefik.svc.cluster.local"` |
| `global.multicluster.child.mcp.entryPoint` | `"web"` |
| `global.multicluster.child.mcp.groups` | (object) |
| `global.multicluster.child.mcp.groups.flightOps` | `""` |
| `global.multicluster.child.mcp.groups.passengerSvc` | `""` |
| `global.multicluster.child.mcp.groups.airportOps` | `""` |
| `tools-access` | (object) |
| `tools-access.dashboard` | (object) |
| `tools-access.dashboard.token` | `""` |
| `tools-access.dashboard.group` | `"tools"` |
| `users-access` | `"[]"` |
| `eventServer` | (object) |
| `eventServer.image` | `"python:3.11-slim"` |
| `aiGateway` | (object) |
| `aiGateway.enabled` | `false` |
| `aiGateway.url` | `""` |
| `aiGateway.token` | `""` |
| `aiGateway.mcpServers` | `"[]"` |
| `aiGateway.multicluster` | (object) |
| `aiGateway.multicluster.child` | (object) |
| `aiGateway.multicluster.child.uplinkEntryPoint` | `"ai-gateway"` |
| `aiGateway.sharedMiddlewares` | (object) |
| `aiGateway.sharedMiddlewares.topicControl` | (object) |
| `aiGateway.sharedMiddlewares.topicControl.enabled` | `true` |
| `aiGateway.sharedMiddlewares.contentSafety` | (object) |
| `aiGateway.sharedMiddlewares.contentSafety.enabled` | `true` |
| `aiGateway.sharedMiddlewares.jailbreakDetection` | (object) |
| `aiGateway.sharedMiddlewares.jailbreakDetection.enabled` | `true` |
| `aiGateway.sharedMiddlewares.graniteGuardian` | (object) |
| `aiGateway.sharedMiddlewares.graniteGuardian.enabled` | `true` |
| `aiGateway.sharedMiddlewares.contentGuardPresidio` | (object) |
| `aiGateway.sharedMiddlewares.contentGuardPresidio.enabled` | `true` |
| `aiGateway.sharedMiddlewares.contentGuardRegex` | (object) |
| `aiGateway.sharedMiddlewares.contentGuardRegex.enabled` | `true` |
| `aiGateway.sharedMiddlewares.semanticCache` | (object) |
| `aiGateway.sharedMiddlewares.semanticCache.enabled` | `false` |
| `hoppscotch` | (object) |
| `hoppscotch.enabled` | `true` |
| `hoppscotch.subdomain` | `"test"` |
| `hoppscotch.image` | `"hoppscotch/hoppscotch:2026.2.0"` |
| `hoppscotch.jwtSecret` | `"airlines-demo-jwt-secret-32chars!"` |
| `hoppscotch.sessionSecret` | `"airlines-demo-session-32chars-ok"` |
| `hoppscotch.dataEncryptionKey` | `"airlines-demo-encrypt-32chars-ok"` |
| `hoppscotch.collections` | (list, 1 items) |
| `keycloak` | (object) |
| `keycloak.enabled` | `true` |
| `keycloak.realm` | (object) |
| `keycloak.realm.enabled` | `true` |
| `keycloak.realm.name` | `"traefik"` |
| `keycloak.realm.users` | (list, 1 items) |
| `keycloak.realm.advancedUsers` | (list, 5 items) |
| `keycloak.realm.extraUsers` | `"[]"` |
| `keycloak.realm.extraAdvancedUsers` | `"[]"` |
| `keycloak.realm.redirectUris` | (list, 4 items) |
| `keycloak.realm.extraRedirectUris` | `"[]"` |
| `keycloak.ingress` | (object) |
| `keycloak.ingress.enabled` | `true` |
| `keycloak.ingress.domain` | `""` |
| `keycloak.ingress.entrypoint` | `"websecure"` |
| `keycloak.ingressInternal` | (object) |
| `keycloak.ingressInternal.enabled` | `false` |
| `keycloak.oidc` | (object) |
| `keycloak.oidc.clientId` | `""` |
| `keycloak.oidc.clientSecret` | `""` |
| `keycloak.oidc.issuerUrl` | `""` |

<!-- END_HELM_DOCS -->
