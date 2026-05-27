# Agent guide — `terraform/traefik/`

Inherits from [`../../CLAUDE.md`](../../CLAUDE.md). This is the most opinionated section because Traefik is the central demo subject.

## Scope

Traefik installs and Traefik configuration logic across every supported platform.

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
