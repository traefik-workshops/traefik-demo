# Agent guide — `terraform/compute/`

Inherits from [`../../CLAUDE.md`](../../CLAUDE.md). This section has the most platform variation, so the rules are tighter.

## Scope

IaaS, managed k8s, base networking. Cluster add-ons live in `terraform/tools/`, not here.

## Modules in this section

Live-derived; regenerate with `make discover | jq '.modules[] | select(.path | startswith("terraform/compute/"))'`.

| Module | Purpose |
|---|---|
| [`akamai/lke`](./akamai/lke) | Akamai/Linode Kubernetes Engine cluster — optional GPU pool, HA control plane, extra worker pools. |
| [`aws/ec2`](./aws/ec2) | EC2 fleet from an `apps` map (replicas, Docker user-data, optional VPC creation). |
| [`aws/ecs`](./aws/ecs) | One or more ECS clusters + task definitions/services from a nested `clusters` map. |
| [`aws/eks`](./aws/eks) | EKS cluster via the upstream community module, demo-friendly defaults. |
| [`aws/vpc`](./aws/vpc) | AWS VPC + public/private subnets via the community `terraform-aws-modules/vpc` module + a demo SG. |
| [`azure/aks`](./azure/aks) | AKS cluster — optional GPU node pool, extra worker pools per `worker_nodes` entry. |
| [`digitalocean/doks`](./digitalocean/doks) | DigitalOcean Kubernetes cluster — optional autoscaling, extra worker pools. |
| [`gcp/gke`](./gcp/gke) | GKE cluster — optional GPU pool, extra worker pools. |
| [`nutanix/categories`](./nutanix/categories) | Prism Central categories and values from a map. |
| [`nutanix/fip`](./nutanix/fip) | Allocates a Nutanix Floating IP and binds it to a VM NIC or VPC private IP. |
| [`nutanix/nkp`](./nutanix/nkp) | End-to-end NKP cluster: bastion VM, control plane VIP, optional FIP, Kommander, kubeconfig extraction. |
| [`nutanix/nkp/bastion_image`](./nutanix/nkp/bastion_image) | Extracts the NKP bastion image from the bundle and uploads as a `nutanix_image`. |
| [`nutanix/nkp/kommander`](./nutanix/nkp/kommander) | FIP for the Kommander/Traefik LoadBalancer service and wires the cluster Service to it. |
| [`nutanix/nkp/registry`](./nutanix/nkp/registry) | Self-hosted container registry VM for use as an NKP mirror. |
| [`nutanix/nkp/registry_image`](./nutanix/nkp/registry_image) | Extracts the NKP registry image from the bundle and uploads as a `nutanix_image`. |
| [`nutanix/storage_container`](./nutanix/storage_container) | Storage container with configurable RF, compression, and erasure coding. |
| [`nutanix/subnet`](./nutanix/subnet) | VLAN-backed Nutanix subnet with optional external flag + DNS. |
| [`nutanix/vm`](./nutanix/vm) | Nutanix VM from a source image — cloud-init, static IP, Prism categories. |
| [`nutanix/vpc`](./nutanix/vpc) | Nutanix VPC + overlay subnets, configurable DNS and externally-routable prefixes. |
| [`oracle/oke`](./oracle/oke) | Oracle Kubernetes Engine cluster — optional extra node pools. |
| [`runpod/auth`](./runpod/auth) | RunPod registry auth (NGC credentials) via the GraphQL API. |
| [`runpod/pod`](./runpod/pod) | Map of RunPod pods, optional registry auth for private images + HF/NGC token forwarding. |
| [`suse/k3d`](./suse/k3d) | Local k3d (k3s-in-Docker) cluster via the SneakyBugs provider — workers, ports, volumes, registry mirroring. |

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
- Don't hardcode credentials. Route through `var.<name>` (`sensitive = true`); demo defaults are acceptable, in-resource literals are not.
- Don't pin to a Kubernetes patch version. Pin to a minor and let the cloud pick the patch.
- Don't add a new cloud without copying the closest sibling first.
