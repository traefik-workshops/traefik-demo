# helm/

Helm charts used to build Traefik demos. Each chart is installed into a Kubernetes cluster as part of a larger demo — they are not standalone applications.

Charts are published to `oci://ghcr.io/traefik-workshops/<chart>` on every repo tag push. Chart versions are **slaved to the repo tag** — when the repo tags `vX.Y.Z`, every `Chart.yaml` `version:` is bumped to `X.Y.Z` and every chart is pushed at that version. So a consumer can pin everything to one number:

```hcl
# Terraform module
module "ai_gateway_demo" {
  source = "git::https://github.com/<org>/traefik-demo.git//compute/aws/eks?ref=v3.2.0"
}
```

```bash
# Helm chart from the same tag
helm install ai-gateway oci://ghcr.io/traefik-workshops/ai-gateway --version 3.2.0
```

If a chart's *upstream* app changes version, that lives in `appVersion` and moves independently.

## Charts

| Chart | Purpose | App version |
|---|---|---|
| [`ai-gateway`](./ai-gateway) | AI gateway with shared middlewares (Presidio, NeMo Guardrails, Weaviate semantic cache) | 1.0.0 |
| [`airlines`](./airlines) | Full airlines-demo umbrella — APIs, dashboards, MCP servers, Hoppscotch, Keycloak | 2.0.0 |
| [`dns-traefiker`](./dns-traefiker) | DNS automation sidecar — keeps a wildcard-style record pointing at the right LB | v1.0.2 |
| [`embeddings`](./embeddings) | Lightweight embedding server (Infinity) — used by ai-gateway's semantic cache | 0.0.75 |
| [`hoppscotch`](./hoppscotch) | Self-hosted Hoppscotch + nginx-served demo collections | 2026.2.0 |
| [`keycloak`](./keycloak) | Keycloak operator + realm + seeded demo users | 26.5.2 |
| [`presidio`](./presidio) | Microsoft Presidio Analyzer — PII detection backend for ai-gateway | 2.2.358 |

Two charts compose others via subchart dependencies. The dependency graph:

```
airlines ── keycloak
        │
        ├── hoppscotch
        │
        └── ai-gateway ── presidio
                       │
                       ├── embeddings
                       │
                       └── weaviate (upstream)
```

When you install `airlines`, you get the whole graph by default — gate sub-features off via the `enabled` flags in `values.yaml`.

## Installing a chart

### From OCI (recommended)

```bash
helm install my-airlines oci://ghcr.io/traefik-workshops/airlines --version 3.2.0
```

Each chart's own README has its install snippet and the values you typically override.

### From source (development)

```bash
cd helm/airlines
helm dep update
helm install my-airlines .
```

`helm dep update` pulls subcharts from the sibling directories via `file://` URLs. The CI publish workflow rewrites these to `oci://` before pushing so consumers pulling from OCI don't see the file paths.

## Where to look next

- [Conventions for charts](./AGENTS.md) — section-specific rules, on top of [the root AGENTS.md](../AGENTS.md)
- Open issues in helm/ — the `HELM-*` and `CHART-*` series
- [Testing posture](../TESTING.md#helm) — lint + ct + values-schema for charts
- Per-chart `README.md` — install snippet, values table (auto-generated)
