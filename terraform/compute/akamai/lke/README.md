# compute/akamai/lke

Provisions an Akamai/Linode Kubernetes Engine (LKE) cluster with optional GPU pool, HA control plane, and extra worker pools.

## Example usage

```hcl
module "lke" {
  source = "git::https://github.com/traefik/traefik-demo.git//terraform/compute/akamai/lke?ref=v4.0.0"

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
| ---- | ------- |
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.3 |
| <a name="requirement_helm"></a> [helm](#requirement\_helm) | ~> 3.0 |
| <a name="requirement_kubernetes"></a> [kubernetes](#requirement\_kubernetes) | ~> 2.0 |
| <a name="requirement_linode"></a> [linode](#requirement\_linode) | ~> 3.0 |
| <a name="requirement_null"></a> [null](#requirement\_null) | ~> 3.0 |

## Providers

| Name | Version |
| ---- | ------- |
| <a name="provider_helm"></a> [helm](#provider\_helm) | ~> 3.0 |
| <a name="provider_kubernetes"></a> [kubernetes](#provider\_kubernetes) | ~> 2.0 |
| <a name="provider_linode"></a> [linode](#provider\_linode) | ~> 3.0 |
| <a name="provider_null"></a> [null](#provider\_null) | ~> 3.0 |

## Resources

| Name | Type |
| ---- | ---- |
| [helm_release.metrics_server](https://registry.terraform.io/providers/hashicorp/helm/latest/docs/resources/release) | resource |
| [kubernetes_storage_class_v1.default](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/storage_class_v1) | resource |
| [linode_lke_cluster.traefik_demo](https://registry.terraform.io/providers/linode/linode/latest/docs/resources/lke_cluster) | resource |
| [null_resource.lke_cluster](https://registry.terraform.io/providers/hashicorp/null/latest/docs/resources/resource) | resource |
| [null_resource.wait](https://registry.terraform.io/providers/hashicorp/null/latest/docs/resources/resource) | resource |

## Inputs

| Name | Description | Type | Default | Required |
| ---- | ----------- | ---- | ------- | :------: |
| <a name="input_cluster_name"></a> [cluster\_name](#input\_cluster\_name) | LKE cluster name | `string` | n/a | yes |
| <a name="input_cluster_location"></a> [cluster\_location](#input\_cluster\_location) | LKE cluster location | `string` | `"us-sea"` | no |
| <a name="input_cluster_name_prefix"></a> [cluster\_name\_prefix](#input\_cluster\_name\_prefix) | LKE cluster name prefix | `string` | `"lke-"` | no |
| <a name="input_cluster_node_count"></a> [cluster\_node\_count](#input\_cluster\_node\_count) | Number of nodes for the cluster | `number` | `1` | no |
| <a name="input_cluster_node_type"></a> [cluster\_node\_type](#input\_cluster\_node\_type) | Default machine type for cluster | `string` | `"g6-standard-2"` | no |
| <a name="input_control_plane_high_availability"></a> [control\_plane\_high\_availability](#input\_control\_plane\_high\_availability) | Enable high availability for control plane | `bool` | `false` | no |
| <a name="input_enable_gpu"></a> [enable\_gpu](#input\_enable\_gpu) | Enable GPU node pool | `bool` | `false` | no |
| <a name="input_gpu_node_count"></a> [gpu\_node\_count](#input\_gpu\_node\_count) | GPU node count | `number` | `1` | no |
| <a name="input_gpu_node_type"></a> [gpu\_node\_type](#input\_gpu\_node\_type) | GPU node type | `string` | `"g2-gpu-rtx4000a1-m"` | no |
| <a name="input_lke_version"></a> [lke\_version](#input\_lke\_version) | LKE Kubernetes version | `string` | `"1.35"` | no |
| <a name="input_node_labels"></a> [node\_labels](#input\_node\_labels) | Labels to apply to the default node pool nodes | `map(string)` | `{}` | no |
| <a name="input_update_kubeconfig"></a> [update\_kubeconfig](#input\_update\_kubeconfig) | Update kubeconfig after cluster creation | `bool` | `true` | no |
| <a name="input_worker_nodes"></a> [worker\_nodes](#input\_worker\_nodes) | Worker node pool definitions. Each entry creates a dedicated pool with the given label and taint. | <pre>list(object({<br/>    label = string<br/>    taint = string<br/>    count = number<br/>  }))</pre> | `[]` | no |

## Outputs

| Name | Description |
| ---- | ----------- |
| <a name="output_cluster_ca_certificate"></a> [cluster\_ca\_certificate](#output\_cluster\_ca\_certificate) | LKE cluster CA certificate |
| <a name="output_cluster_id"></a> [cluster\_id](#output\_cluster\_id) | LKE cluster ID |
| <a name="output_host"></a> [host](#output\_host) | LKE cluster host |
| <a name="output_kubeconfig"></a> [kubeconfig](#output\_kubeconfig) | LKE cluster kubeconfig |
| <a name="output_token"></a> [token](#output\_token) | LKE cluster auth token |
<!-- END_TF_DOCS -->
