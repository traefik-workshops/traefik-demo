# Agent guide — `terraform/traefik/`

Inherits from [`../../CLAUDE.md`](../../CLAUDE.md). This is the most opinionated section because Traefik is the central demo subject.

## Scope

Traefik installs and Traefik configuration logic across every supported platform.

## Modules in this section

Live-derived; regenerate with `make discover | jq '.modules[] | select(.path | startswith("terraform/traefik/"))'`.

| Module | Purpose |
|---|---|
| [`shared`](./shared) | Library module: takes inputs, renders the upstream Traefik Helm chart, exposes CLI args / env vars / ports / image refs / static config. Consumed by every platform module below. |
| [`cloud-init`](./cloud-init) | Template module: renders cloud-init for VM installs (Keepalived VRRP, OTLP, perf tuning, DNS Traefiker). No resources — output-only. |
| [`k8s`](./k8s) | Traefik Hub on Kubernetes via Helm — full feature-flag matrix (API Gateway, AI Gateway, MCP Gateway, API Management, Knative provider). |
| [`ec2`](./ec2) | Traefik Hub on AWS EC2 — wires `shared` + `cloud-init`. Optional Elastic IP and ACME sync. |
| [`ecs`](./ecs) | Traefik Hub on AWS ECS — wires `shared` + `compute/aws/ecs`. |
| [`nutanix`](./nutanix) | Traefik Hub VM on Nutanix AHV via `compute/nutanix/vm` — wires `shared` + `cloud-init`. Optional Keepalived HA. |

## Architecture

```
terraform/traefik/shared/         # library module: takes inputs, emits config strings
terraform/traefik/cloud-init/     # template module: builds cloud-init using shared outputs
traefik/<platform>/     # platform module: provisions infra, applies the install
```

## Rules

1. **Don't duplicate config logic.** If you find yourself building Helm values or static config in a platform module, the logic belongs in `shared/`.
2. **Every platform module composes from `shared/`.** Don't reach around it.
3. **Feature flags are added to `shared/` once.** Each platform module passes them through. Adding a flag in only one platform creates drift.
4. **Outputs from platform modules** include at least: `dashboard_url`, the relevant ingress identifier (`load_balancer_ip` for k8s, `public_ips` for ec2, `ip_address` for nutanix).

## Required outputs (platform modules)

- `dashboard_url`
- The ingress address(es): `load_balancer_ip` (k8s) / `public_ips` (ec2) / `services` (ecs) / `ip_address` (nutanix)

## Don't

- Don't add a new Traefik feature flag in a platform module without also adding it to `shared/`.
- Don't add a non-Traefik ingress controller here. Other ingress controllers go in `terraform/tools/`.
- Don't pin the Traefik image version in defaults to anything stale. Track the current `latest` channel; let advanced users pin.
