# compute/azure/aks

Provisions an Azure Kubernetes Service (AKS) cluster with optional GPU node pool and extra worker pools (one per `worker_nodes` entry).

## Example usage

```hcl
module "aks" {
  source = "git::https://github.com/traefik/traefik-demo.git//terraform/compute/azure/aks?ref=v3.2.0"

  cluster_name        = "demo"
  resource_group_name = "demo-rg"
  cluster_location    = "westus"
  aks_version         = "1.34"
}
```

## Prerequisites

- Azure credentials with AKS/Resource Group permissions.
- `kubectl` on PATH if `update_kubeconfig = true`.

<!-- BEGIN_TF_DOCS -->

## Requirements

| Name | Version |
|------|---------|
| azurerm | ~> 4.0 |

## Providers

| Name | Source | Version |
|------|--------|---------|
| azurerm | `hashicorp/azurerm` | `~> 4.0` |

## Resources

| Name | Type |
|------|------|
| `azurerm_kubernetes_cluster.traefik_demo` | resource |
| `null_resource.aks_default_taint` | resource |
| `azurerm_kubernetes_cluster_node_pool.worker` | resource |
| `azurerm_kubernetes_cluster_node_pool.traefik_demo_gpu` | resource |
| `null_resource.aks_cluster` | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| cluster_name | AKS cluster name | `string` | n/a | yes |
| resource_group_name | Resource group name | `string` | n/a | yes |
| aks_version | AKS Kubernetes version | `string` | `"1.34"` | no |
| cluster_location | AKS cluster location | `string` | `"westus"` | no |
| cluster_node_count | Number of nodes for the cluster | `number` | `1` | no |
| cluster_node_type | Default node type for cluster | `string` | `"Standard_B2s"` | no |
| enable_gpu | Enable GPU nodes | `bool` | `false` | no |
| gpu_node_count | Number of GPU nodes for the cluster | `number` | `1` | no |
| gpu_node_type | GPU node type for cluster | `string` | `""` | no |
| update_kubeconfig | Update kubeconfig after cluster creation | `bool` | `true` | no |
| worker_nodes | Worker node pool definitions. Each entry creates a dedicated node pool with the given label and taint. | `list(object({label = string, taint = string, count = number))` | `[]` | no |

## Outputs

| Name | Description |
|------|-------------|
| client_certificate | AKS cluster client certificate |
| client_key | AKS cluster client key |
| cluster_ca_certificate | AKS cluster CA certificate |
| host | AKS cluster host |

<!-- END_TF_DOCS -->
