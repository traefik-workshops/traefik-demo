# compute/digitalocean/doks

Provisions a DigitalOcean Kubernetes (DOKS) cluster with optional autoscaling and extra worker pools.

## Example usage

```hcl
module "doks" {
  source = "git::https://github.com/traefik/traefik-demo.git//terraform/compute/digitalocean/doks?ref=v4.0.0"

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
| ---- | ------- |
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.3 |
| <a name="requirement_digitalocean"></a> [digitalocean](#requirement\_digitalocean) | ~> 2.0 |
| <a name="requirement_helm"></a> [helm](#requirement\_helm) | ~> 3.0 |
| <a name="requirement_null"></a> [null](#requirement\_null) | ~> 3.0 |

## Providers

| Name | Version |
| ---- | ------- |
| <a name="provider_digitalocean"></a> [digitalocean](#provider\_digitalocean) | ~> 2.0 |
| <a name="provider_helm"></a> [helm](#provider\_helm) | ~> 3.0 |
| <a name="provider_null"></a> [null](#provider\_null) | ~> 3.0 |

## Resources

| Name | Type |
| ---- | ---- |
| [digitalocean_kubernetes_cluster.traefik_demo](https://registry.terraform.io/providers/digitalocean/digitalocean/latest/docs/resources/kubernetes_cluster) | resource |
| [digitalocean_kubernetes_node_pool.worker](https://registry.terraform.io/providers/digitalocean/digitalocean/latest/docs/resources/kubernetes_node_pool) | resource |
| [helm_release.metrics_server](https://registry.terraform.io/providers/hashicorp/helm/latest/docs/resources/release) | resource |
| [null_resource.doks_cluster](https://registry.terraform.io/providers/hashicorp/null/latest/docs/resources/resource) | resource |
| [null_resource.wait](https://registry.terraform.io/providers/hashicorp/null/latest/docs/resources/resource) | resource |

## Inputs

| Name | Description | Type | Default | Required |
| ---- | ----------- | ---- | ------- | :------: |
| <a name="input_cluster_name"></a> [cluster\_name](#input\_cluster\_name) | DOKS cluster name | `string` | n/a | yes |
| <a name="input_cluster_location"></a> [cluster\_location](#input\_cluster\_location) | DOKS cluster region | `string` | `"nyc2"` | no |
| <a name="input_cluster_node_count"></a> [cluster\_node\_count](#input\_cluster\_node\_count) | Number of nodes for the cluster | `number` | `1` | no |
| <a name="input_cluster_node_type"></a> [cluster\_node\_type](#input\_cluster\_node\_type) | Default droplet size for cluster nodes | `string` | `"s-1vcpu-2gb"` | no |
| <a name="input_doks_version"></a> [doks\_version](#input\_doks\_version) | DOKS Kubernetes version | `string` | `"1.33.1-do.3"` | no |
| <a name="input_enable_autoscaling"></a> [enable\_autoscaling](#input\_enable\_autoscaling) | Enable autoscaling for default node pool | `bool` | `false` | no |
| <a name="input_max_nodes"></a> [max\_nodes](#input\_max\_nodes) | Maximum number of nodes in the default node pool | `number` | `1` | no |
| <a name="input_min_nodes"></a> [min\_nodes](#input\_min\_nodes) | Minimum number of nodes in the default node pool | `number` | `1` | no |
| <a name="input_namespace"></a> [namespace](#input\_namespace) | Kubernetes namespace to use for resources | `string` | `"default"` | no |
| <a name="input_update_kubeconfig"></a> [update\_kubeconfig](#input\_update\_kubeconfig) | Update kubeconfig after cluster creation | `bool` | `true` | no |
| <a name="input_worker_nodes"></a> [worker\_nodes](#input\_worker\_nodes) | Worker node pool definitions. Each entry creates a dedicated node pool with the given label and taint. | <pre>list(object({<br/>    label = string<br/>    taint = string<br/>    count = number<br/>  }))</pre> | `[]` | no |

## Outputs

| Name | Description |
| ---- | ----------- |
| <a name="output_cluster_ca_certificate"></a> [cluster\_ca\_certificate](#output\_cluster\_ca\_certificate) | DOKS cluster CA certificate |
| <a name="output_cluster_id"></a> [cluster\_id](#output\_cluster\_id) | DOKS cluster ID |
| <a name="output_cluster_name"></a> [cluster\_name](#output\_cluster\_name) | DOKS cluster name |
| <a name="output_endpoint"></a> [endpoint](#output\_endpoint) | DOKS cluster endpoint |
| <a name="output_host"></a> [host](#output\_host) | DOKS cluster host |
| <a name="output_kubeconfig"></a> [kubeconfig](#output\_kubeconfig) | DOKS cluster kubeconfig |
| <a name="output_namespace"></a> [namespace](#output\_namespace) | Namespace consumers should deploy demo workloads into on this cluster. |
| <a name="output_region"></a> [region](#output\_region) | DOKS cluster region |
| <a name="output_token"></a> [token](#output\_token) | DOKS cluster auth token |
| <a name="output_version"></a> [version](#output\_version) | DOKS cluster Kubernetes version |
<!-- END_TF_DOCS -->
