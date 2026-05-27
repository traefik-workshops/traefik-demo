# compute/digitalocean/doks

Provisions a DigitalOcean Kubernetes (DOKS) cluster with optional autoscaling and extra worker pools.

## Example usage

```hcl
module "doks" {
  source = "git::https://github.com/traefik/terraform-demo-modules.git//terraform/compute/digitalocean/doks?ref=v3.2.0"

  cluster_name     = "demo"
  cluster_location = "nyc2"
  doks_version     = "1.33.1-do.3"
}
```

## Prerequisites

- A DigitalOcean API token (`DIGITALOCEAN_TOKEN`).
- `kubectl` on PATH if `update_kubeconfig = true`.

<!-- BEGIN_TF_DOCS -->

## Requirements

| Name | Version |
|------|---------|
| digitalocean | ~> 2.0 |

## Providers

| Name | Source | Version |
|------|--------|---------|
| digitalocean | `digitalocean/digitalocean` | `~> 2.0` |

## Resources

| Name | Type |
|------|------|
| `digitalocean_kubernetes_cluster.traefik_demo` | resource |
| `digitalocean_kubernetes_node_pool.worker` | resource |
| `null_resource.wait` | resource |
| `null_resource.doks_cluster` | resource |
| `helm_release.metrics_server` | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| cluster_name | DOKS cluster name | `string` | n/a | yes |
| cluster_location | DOKS cluster region | `string` | `"nyc2"` | no |
| cluster_node_count | Number of nodes for the cluster | `number` | `1` | no |
| cluster_node_type | Default droplet size for cluster nodes | `string` | `"s-1vcpu-2gb"` | no |
| doks_version | DOKS Kubernetes version | `string` | `"1.33.1-do.3"` | no |
| enable_autoscaling | Enable autoscaling for default node pool | `bool` | `false` | no |
| max_nodes | Maximum number of nodes in the default node pool | `number` | `1` | no |
| min_nodes | Minimum number of nodes in the default node pool | `number` | `1` | no |
| namespace | Kubernetes namespace to use for resources | `string` | `"default"` | no |
| update_kubeconfig | Update kubeconfig after cluster creation | `bool` | `true` | no |
| worker_nodes | Worker node pool definitions. Each entry creates a dedicated node pool with the given label and taint. | `list(object({label = string, taint = string, count = number))` | `[]` | no |

## Outputs

| Name | Description |
|------|-------------|
| cluster_ca_certificate 🔒 | DOKS cluster CA certificate |
| cluster_id 🔒 | DOKS cluster ID |
| cluster_name | DOKS cluster name |
| endpoint | DOKS cluster endpoint |
| host 🔒 | DOKS cluster host |
| kubeconfig 🔒 | DOKS cluster kubeconfig |
| region | DOKS cluster region |
| token 🔒 | DOKS cluster auth token |
| version | DOKS cluster Kubernetes version |

<!-- END_TF_DOCS -->
