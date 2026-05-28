# compute/gcp/gke

Provisions a Google Kubernetes Engine (GKE) cluster with optional GPU pool and extra worker pools.

## Example usage

```hcl
module "gke" {
  source = "git::https://github.com/traefik/traefik-demo.git//terraform/compute/gcp/gke?ref=v3.2.0"

  cluster_name     = "demo"
  cluster_location = "us-west1-a"
}
```

## Prerequisites

- GCP credentials with GKE/Compute permissions.
- `kubectl` and `gcloud` on PATH if `update_kubeconfig = true`.

<!-- BEGIN_TF_DOCS -->

## Requirements

| Name | Version |
|------|---------|
| google | ~> 6.0 |

## Providers

| Name | Source | Version |
|------|--------|---------|
| google | `hashicorp/google` | `~> 6.0` |

## Resources

| Name | Type |
|------|------|
| `google_container_cluster.traefik_demo` | resource |
| `google_container_node_pool.worker` | resource |
| `google_container_node_pool.traefik_demo_gpu` | resource |
| `null_resource.gke_cluster` | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| cluster_name | GKE cluster name. | `string` | n/a | yes |
| cluster_location | GKE cluster location. | `string` | `"us-west1-a"` | no |
| cluster_node_count | Number of nodes for the cluster. | `number` | `1` | no |
| cluster_node_type | Default machine type for cluster | `string` | `"e2-standard-2"` | no |
| enable_gpu | Enable GPU node pool | `bool` | `false` | no |
| gke_version | GKE cluster version. | `string` | `""` | no |
| gpu_count | GPU count | `number` | `1` | no |
| gpu_node_count | GPU node count | `number` | `1` | no |
| gpu_node_type | GPU node type | `string` | `"g2-standard-8"` | no |
| gpu_type | GPU type | `string` | `"nvidia-l4"` | no |
| update_kubeconfig | Update kubeconfig after cluster creation | `bool` | `true` | no |
| worker_nodes | Worker node pool definitions. Each entry creates a dedicated node pool with the given label and taint. | `list(object({label = string, taint = string, count = number))` | `[]` | no |

## Outputs

| Name | Description |
|------|-------------|
| cluster_ca_certificate | GKE cluster CA certificate |
| host | GKE cluster host (endpoint) |
| token | GKE cluster auth token |

<!-- END_TF_DOCS -->
