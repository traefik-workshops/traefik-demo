# compute/akamai/lke

Provisions an Akamai/Linode Kubernetes Engine (LKE) cluster with optional GPU pool, HA control plane, and extra worker pools.

## Example usage

```hcl
module "lke" {
  source = "git::https://github.com/traefik/traefik-demo.git//terraform/compute/akamai/lke?ref=v3.2.0"

  cluster_name     = "demo"
  cluster_location = "us-sea"
  lke_version      = "1.35"
}
```

## Prerequisites

- A Linode API token (`LINODE_TOKEN`).
- `kubectl` on PATH if `update_kubeconfig = true`.

<!-- BEGIN_TF_DOCS -->

## Requirements

| Name | Version |
|------|---------|
| linode | ~> 3.0 |

## Providers

| Name | Source | Version |
|------|--------|---------|
| linode | `linode/linode` | `~> 3.0` |

## Resources

| Name | Type |
|------|------|
| `linode_lke_cluster.traefik_demo` | resource |
| `null_resource.wait` | resource |
| `null_resource.lke_cluster` | resource |
| `helm_release.metrics_server` | resource |
| `kubernetes_storage_class_v1.default` | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| cluster_name | LKE cluster name | `string` | n/a | yes |
| cluster_location | LKE cluster location | `string` | `"us-sea"` | no |
| cluster_name_prefix | LKE cluster name prefix | `string` | `"lke-"` | no |
| cluster_node_count | Number of nodes for the cluster | `number` | `1` | no |
| cluster_node_type | Default machine type for cluster | `string` | `"g6-standard-2"` | no |
| control_plane_high_availability | Enable high availability for control plane | `bool` | `false` | no |
| enable_gpu | Enable GPU node pool | `bool` | `false` | no |
| gpu_node_count | GPU node count | `number` | `1` | no |
| gpu_node_type | GPU node type | `string` | `"g2-gpu-rtx4000a1-m"` | no |
| lke_version | LKE Kubernetes version | `string` | `"1.35"` | no |
| node_labels | Labels to apply to the default node pool nodes | `map(string)` | `{}` | no |
| update_kubeconfig | Update kubeconfig after cluster creation | `bool` | `true` | no |
| worker_nodes | Worker node pool definitions. Each entry creates a dedicated pool with the given label and taint. | `list(object({label = string, taint = string, count = number))` | `[]` | no |

## Outputs

| Name | Description |
|------|-------------|
| cluster_ca_certificate 🔒 | LKE cluster CA certificate |
| cluster_id 🔒 | LKE cluster ID |
| host 🔒 | LKE cluster host |
| kubeconfig 🔒 | LKE cluster kubeconfig |
| token 🔒 | LKE cluster auth token |

<!-- END_TF_DOCS -->
