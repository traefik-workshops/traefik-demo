# Agent guide — `terraform/tools/`

Inherits from [`../../CLAUDE.md`](../../CLAUDE.md).

## Scope

Cluster add-ons that aren't observability, security, or Traefik. The "everything else" of the cluster.

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
