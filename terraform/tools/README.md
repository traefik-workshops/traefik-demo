# tools/

Cluster add-ons that don't fit observability or security. Each is a thin Helm wrapper with demo-friendly defaults.

## Modules

| Path | Purpose |
|---|---|
| [`argocd/k8s`](./argocd/k8s) | ArgoCD (GitOps) with optional ingress |
| [`cert-manager/k8s`](./cert-manager/k8s) | cert-manager (TLS certs) |
| [`cloudflare`](./cloudflare) | Cloudflare DNS records (not k8s; manages records in your zone) |
| [`k6-operator/k8s`](./k6-operator/k8s) | Grafana k6 operator (load testing) |
| [`k6-operator/k8s/loadgen/aigateway`](./k6-operator/k8s/loadgen/aigateway) | Load-gen scenarios targeting the AI gateway |
| [`mcp-inspector/k8s`](./mcp-inspector/k8s) | MCP Inspector (debug UI for MCP servers) |
| [`nginx/k8s`](./nginx/k8s) | NGINX ingress controller |
| [`postgresql/k8s`](./postgresql/k8s) | PostgreSQL (Bitnami chart, dev settings) |
| [`redis/k8s`](./redis/k8s) | Redis (Bitnami chart, dev settings) |

## What "tools" means

A module belongs here if:

- It's a *cluster-scoped add-on* (something every other demo workload might depend on).
- It's not an IdP (those live in `terraform/security/`).
- It's not an observability backend (those live in `terraform/observability/`).
- It's not Traefik (that has its own top-level section).

If a module would be a stretch to fit elsewhere, default to `terraform/tools/`.

## Known issues

- All modules in this section have no `outputs.tf`. Most are fine (the Helm provider exposes everything), but ArgoCD should expose `dashboard_url`. See OUT-01 in [`../../ISSUES.md`](../../ISSUES.md).
