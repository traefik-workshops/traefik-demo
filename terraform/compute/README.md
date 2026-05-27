# compute/

Infrastructure-as-a-Service and managed Kubernetes per cloud. **This is the largest and most opinionated section** because each cloud has its own conventions and each managed-k8s offering exposes a slightly different surface.

## Modules

### Public clouds

| Path | Purpose |
|---|---|
| [`aws/ec2`](./aws/ec2) | EC2 instances + optional VPC |
| [`aws/ecs`](./aws/ecs) | ECS Fargate cluster + IAM |
| [`aws/eks`](./aws/eks) | EKS cluster (wraps the community EKS module) |
| [`aws/vpc`](./aws/vpc) | VPC, subnets, route tables |
| [`azure/aks`](./azure/aks) | AKS cluster + kubeconfig outputs |
| [`gcp/gke`](./gcp/gke) | GKE cluster + kubeconfig outputs |
| [`digitalocean/doks`](./digitalocean/doks) | DOKS cluster (rich output set) |
| [`oracle/oke`](./oracle/oke) | OKE cluster (uses TLS provider for certs) |
| [`akamai/lke`](./akamai/lke) | LKE (Linode Kubernetes Engine) |

### On-prem / private cloud (Nutanix)

| Path | Purpose |
|---|---|
| [`nutanix/vpc`](./nutanix/vpc) | VPC + subnets |
| [`nutanix/subnet`](./nutanix/subnet) | Single subnet |
| [`nutanix/fip`](./nutanix/fip) | Floating IP |
| [`nutanix/vm`](./nutanix/vm) | Virtual machine |
| [`nutanix/storage_container`](./nutanix/storage_container) | Storage container |
| [`nutanix/categories`](./nutanix/categories) | Nutanix categories (tagging) |
| [`nutanix/nkp`](./nutanix/nkp) | Full NKP (Nutanix Kubernetes Platform) cluster |
| [`nutanix/nkp/bastion_image`](./nutanix/nkp/bastion_image) | NKP bastion image (Packer) |
| [`nutanix/nkp/kommander`](./nutanix/nkp/kommander) | NKP Kommander management plane |
| [`nutanix/nkp/registry`](./nutanix/nkp/registry) | NKP private registry VM |
| [`nutanix/nkp/registry_image`](./nutanix/nkp/registry_image) | NKP registry image (Packer) |

### Specialized

| Path | Purpose |
|---|---|
| [`runpod/auth`](./runpod/auth) | RunPod NGC registry credentials (one-time setup) |
| [`runpod/pod`](./runpod/pod) | A RunPod GPU pod |
| [`suse/k3d`](./suse/k3d) | k3d local cluster (laptop demos) |

## Standard cluster outputs

Every managed-k8s module exposes the same five outputs so downstream `helm`/`kubernetes` providers are configured the same way regardless of cloud:

- `host`
- `cluster_ca_certificate`
- `token`
- `kubeconfig` (string — write to disk if you need `kubectl`)
- `cluster_id` (or equivalent platform identifier)

Some modules add extras (`endpoint`, `region`, `version`, `node_pool_id`). New cluster modules should expose at least the five above.

## When to add a new cloud / managed-k8s

1. Look at the closest existing sibling — they're intentionally similar.
2. Copy its file layout (`main.tf`, `metrics.tf` if relevant, `outputs.tf`, `variables.tf`, `versions.tf`).
3. Match the five standard outputs.
4. Pick a small default node size (free-tier-friendly if the cloud has one).

## Known issues

- **Hardcoded passwords** in `nutanix/nkp/main.tf` and `nutanix/nkp/registry/main.tf` (SEC-01, SEC-02 — critical)
- Missing version constraint on `kubernetes` provider in `nutanix/nkp/kommander` (VER-01)
- RunPod modules missing `versions.tf` (PROV-01)

See [`../../ISSUES.md`](../../ISSUES.md).
