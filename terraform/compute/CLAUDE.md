# Agent guide — `terraform/compute/`

Inherits from [`../../CLAUDE.md`](../../CLAUDE.md). This section has the most platform variation, so the rules are tighter.

## Scope

IaaS, managed k8s, base networking. Cluster add-ons live in `terraform/tools/`, not here.

## Layout

- `terraform/compute/<cloud>/<service>/` for public clouds (e.g. `terraform/compute/aws/eks`).
- `terraform/compute/<cloud>/<resource>/` for on-prem clouds with finer-grained resources (Nutanix splits `vm`, `vpc`, `subnet`, `fip`, `storage_container`, `categories`).
- `terraform/compute/<cloud>/<service>/<sub>` for nested resources (e.g. `terraform/compute/nutanix/nkp/kommander`).

## Required outputs for managed-k8s modules

Every cluster module must expose (at minimum):

```hcl
output "host"                   { value = "..." }
output "cluster_ca_certificate" { value = "..." sensitive = true }
output "token"                  { value = "..." sensitive = true }
output "kubeconfig"             { value = "..." sensitive = true }
output "cluster_id"             { value = "..." }
```

Optional but recommended: `endpoint`, `region`, `version`, `node_pool_id`. See `terraform/compute/digitalocean/doks` for a complete example.

## Required outputs for networking modules

- VPC: `vpc_id`, `private_subnet_ids`, `public_subnet_ids`, `security_group_ids`
- Subnet: `id`
- FIP/Floating IP: `id`, `public_ip`

## Defaults philosophy (cluster-specific)

- **Node count:** smallest viable (1 control + 1-2 workers for managed; whatever the platform's minimum is).
- **Node size:** the cheapest size that runs Helm releases without OOMing — typically 2 vCPU / 4-8 GB.
- **Kubernetes version:** track current minor minus 1 (e.g. if 1.31 is current, default to 1.30). Stale defaults cause "upgrade required" failures on apply.
- **Auto-scaling:** off by default. Predictable cost matters for demos.
- **Logging / monitoring add-ons that cost money:** off by default.

## Don't

- Don't add cluster add-ons here. Add-ons (ingress, cert-manager, ArgoCD, observability) live in `terraform/tools/`, `terraform/observability/`, `terraform/security/`, etc.
- Don't hardcode credentials. See SEC-01/02 in [`../../ISSUES.md`](../../ISSUES.md).
- Don't pin to a Kubernetes patch version. Pin to a minor and let the cloud pick the patch.
- Don't add a new cloud without copying the closest sibling first.
