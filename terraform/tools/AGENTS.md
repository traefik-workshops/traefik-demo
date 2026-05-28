# Agent guide — `terraform/tools/`

Inherits from [`../../AGENTS.md`](../../AGENTS.md).

## Scope

Cluster add-ons that aren't observability, security, or Traefik. The "everything else" of the cluster.

## Modules in this section

Live-derived; regenerate with `make discover | jq '.modules[] | select(.path | startswith("terraform/tools/"))'`.

| Module | Purpose |
|---|---|
| [`argocd/k8s`](./argocd/k8s) | ArgoCD via Helm — explicit admin password, optional Traefik ingress. |
| [`cert-manager/k8s`](./cert-manager/k8s) | cert-manager via Helm. |
| [`cloudflare`](./cloudflare) | Single Cloudflare DNS record (A or CNAME), optional proxying. |
| [`k6-operator/k8s`](./k6-operator/k8s) | Grafana k6 Operator via Helm. |
| [`k6-operator/k8s/loadgen/aigateway`](./k6-operator/k8s/loadgen/aigateway) | k6 `TestRun` for the AI Gateway: per-user JWT, multi-turn conversations across one or more model APIs. |
| [`mcp-inspector/k8s`](./mcp-inspector/k8s) | MCP Inspector UI as a Deployment + Service, optional Traefik ingress. |
| [`nginx/k8s`](./nginx/k8s) | NGINX via Helm. |
| [`postgresql/k8s`](./postgresql/k8s) | PostgreSQL via Helm with configurable password and database name. |
| [`redis/k8s`](./redis/k8s) | Redis via Helm with configurable password and replica count. |

## Sub-conventions

- One module per add-on. Don't bundle (no `terraform/tools/dev-stack/k8s` that installs five things).
- Defaults target *dev usage*: ephemeral storage, single replica, no HA, no LDAP. Expose flags for the production-grade variants.
- `password` variables exist on stateful tools (postgres, redis) — currently passed in as plain variables; consider `random_password` for generated defaults.

## Required outputs

For tools that expose a UI (ArgoCD, MCP Inspector):

- `dashboard_url` (string)
- `admin_user`, `admin_password` (sensitive)

For tools that are pure infra (cert-manager, nginx, k6-operator):

- No outputs needed. Document this in the module README.

## Don't

- Don't put cloud-specific resources here. If the module needs an AWS LB, it's not a tool — it belongs in `terraform/compute/aws/` or as a separate `terraform/traefik/`-style top-level if it's wide enough.
- Don't add an alternative for something already covered. We have one Postgres, one Redis. If you need a different one, talk first.
