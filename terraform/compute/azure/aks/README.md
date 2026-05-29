# compute/azure/aks

Provisions an Azure Kubernetes Service (AKS) cluster with optional GPU node pool and extra worker pools (one per `worker_nodes` entry).

## Example usage

```hcl
module "aks" {
  source = "git::https://github.com/traefik/traefik-demo.git//terraform/compute/azure/aks?ref=v4.0.0"

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
| ---- | ------- |
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.3 |
| <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) | ~> 4.0 |
| <a name="requirement_null"></a> [null](#requirement\_null) | ~> 3.0 |

## Providers

| Name | Version |
| ---- | ------- |
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) | ~> 4.0 |
| <a name="provider_null"></a> [null](#provider\_null) | ~> 3.0 |

## Resources

| Name | Type |
| ---- | ---- |
| [azurerm_kubernetes_cluster.traefik_demo](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/kubernetes_cluster) | resource |
| [azurerm_kubernetes_cluster_node_pool.traefik_demo_gpu](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/kubernetes_cluster_node_pool) | resource |
| [azurerm_kubernetes_cluster_node_pool.worker](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/kubernetes_cluster_node_pool) | resource |
| [null_resource.aks_cluster](https://registry.terraform.io/providers/hashicorp/null/latest/docs/resources/resource) | resource |
| [null_resource.aks_default_taint](https://registry.terraform.io/providers/hashicorp/null/latest/docs/resources/resource) | resource |

## Inputs

| Name | Description | Type | Default | Required |
| ---- | ----------- | ---- | ------- | :------: |
| <a name="input_cluster_name"></a> [cluster\_name](#input\_cluster\_name) | AKS cluster name | `string` | n/a | yes |
| <a name="input_resource_group_name"></a> [resource\_group\_name](#input\_resource\_group\_name) | Resource group name | `string` | n/a | yes |
| <a name="input_aks_version"></a> [aks\_version](#input\_aks\_version) | AKS Kubernetes version | `string` | `"1.34"` | no |
| <a name="input_cluster_location"></a> [cluster\_location](#input\_cluster\_location) | AKS cluster location | `string` | `"westus"` | no |
| <a name="input_cluster_node_count"></a> [cluster\_node\_count](#input\_cluster\_node\_count) | Number of nodes for the cluster | `number` | `1` | no |
| <a name="input_cluster_node_type"></a> [cluster\_node\_type](#input\_cluster\_node\_type) | Default node type for cluster | `string` | `"Standard_B2s"` | no |
| <a name="input_enable_gpu"></a> [enable\_gpu](#input\_enable\_gpu) | Enable GPU nodes | `bool` | `false` | no |
| <a name="input_gpu_node_count"></a> [gpu\_node\_count](#input\_gpu\_node\_count) | Number of GPU nodes for the cluster | `number` | `1` | no |
| <a name="input_gpu_node_type"></a> [gpu\_node\_type](#input\_gpu\_node\_type) | GPU node type for cluster | `string` | `""` | no |
| <a name="input_update_kubeconfig"></a> [update\_kubeconfig](#input\_update\_kubeconfig) | Update kubeconfig after cluster creation | `bool` | `true` | no |
| <a name="input_worker_nodes"></a> [worker\_nodes](#input\_worker\_nodes) | Worker node pool definitions. Each entry creates a dedicated node pool with the given label and taint. | <pre>list(object({<br/>    label = string<br/>    taint = string<br/>    count = number<br/>  }))</pre> | `[]` | no |

## Outputs

| Name | Description |
| ---- | ----------- |
| <a name="output_client_certificate"></a> [client\_certificate](#output\_client\_certificate) | AKS cluster client certificate |
| <a name="output_client_key"></a> [client\_key](#output\_client\_key) | AKS cluster client key |
| <a name="output_cluster_ca_certificate"></a> [cluster\_ca\_certificate](#output\_cluster\_ca\_certificate) | AKS cluster CA certificate |
| <a name="output_host"></a> [host](#output\_host) | AKS cluster host |
<!-- END_TF_DOCS -->
