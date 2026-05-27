# demos/single-cluster

The "hello world." One Kubernetes cluster + Traefik Hub + a `whoami` workload.

## What it proves

- The cluster module's outputs feed the `kubernetes` / `helm` providers correctly.
- Traefik Hub installs and the dashboard is reachable.
- A sample workload behind Traefik resolves at the chosen domain.

## Install

```bash
cp terraform.tfvars.example terraform.tfvars
# edit terraform.tfvars — set domain + traefik_hub_token
terraform init
terraform apply
```

Outputs:
- `dashboard_url` — Traefik dashboard
- `whoami_url` — sample workload

## Extending

- Swap `terraform/compute/digitalocean/doks` for any `terraform/compute/<cloud>` module — the rest of this file is provider-agnostic.
- Add `enable_ai_gateway = true` / `enable_mcp_gateway = true` on the Traefik module to enable more Hub features.
- For SSO, point at [`../oidc-portal`](../oidc-portal) instead.
- For multicluster, point at [`../unified-ingress`](../unified-ingress).
