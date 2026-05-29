# compute/gcp/gke

Provisions a Google Kubernetes Engine (GKE) cluster with optional GPU pool and extra worker pools.

## Example usage

```hcl
module "gke" {
  source = "git::https://github.com/traefik/traefik-demo.git//terraform/compute/gcp/gke?ref=v4.0.0"

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
| ---- | ------- |
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.3 |
| <a name="requirement_google"></a> [google](#requirement\_google) | ~> 6.0 |
| <a name="requirement_null"></a> [null](#requirement\_null) | ~> 3.0 |

## Providers

| Name | Version |
| ---- | ------- |
| <a name="provider_google"></a> [google](#provider\_google) | ~> 6.0 |
| <a name="provider_null"></a> [null](#provider\_null) | ~> 3.0 |

## Resources

| Name | Type |
| ---- | ---- |
| [google_container_cluster.traefik_demo](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/container_cluster) | resource |
| [google_container_node_pool.traefik_demo_gpu](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/container_node_pool) | resource |
| [google_container_node_pool.worker](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/container_node_pool) | resource |
| [null_resource.gke_cluster](https://registry.terraform.io/providers/hashicorp/null/latest/docs/resources/resource) | resource |

## Inputs

| Name | Description | Type | Default | Required |
| ---- | ----------- | ---- | ------- | :------: |
| <a name="input_cluster_name"></a> [cluster\_name](#input\_cluster\_name) | GKE cluster name. | `string` | n/a | yes |
| <a name="input_cluster_location"></a> [cluster\_location](#input\_cluster\_location) | GKE cluster location. | `string` | `"us-west1-a"` | no |
| <a name="input_cluster_node_count"></a> [cluster\_node\_count](#input\_cluster\_node\_count) | Number of nodes for the cluster. | `number` | `1` | no |
| <a name="input_cluster_node_type"></a> [cluster\_node\_type](#input\_cluster\_node\_type) | Default machine type for cluster | `string` | `"e2-standard-2"` | no |
| <a name="input_enable_gpu"></a> [enable\_gpu](#input\_enable\_gpu) | Enable GPU node pool | `bool` | `false` | no |
| <a name="input_gke_version"></a> [gke\_version](#input\_gke\_version) | GKE cluster version. | `string` | `""` | no |
| <a name="input_gpu_count"></a> [gpu\_count](#input\_gpu\_count) | GPU count | `number` | `1` | no |
| <a name="input_gpu_node_count"></a> [gpu\_node\_count](#input\_gpu\_node\_count) | GPU node count | `number` | `1` | no |
| <a name="input_gpu_node_type"></a> [gpu\_node\_type](#input\_gpu\_node\_type) | GPU node type | `string` | `"g2-standard-8"` | no |
| <a name="input_gpu_type"></a> [gpu\_type](#input\_gpu\_type) | GPU type | `string` | `"nvidia-l4"` | no |
| <a name="input_update_kubeconfig"></a> [update\_kubeconfig](#input\_update\_kubeconfig) | Update kubeconfig after cluster creation | `bool` | `true` | no |
| <a name="input_worker_nodes"></a> [worker\_nodes](#input\_worker\_nodes) | Worker node pool definitions. Each entry creates a dedicated node pool with the given label and taint. | <pre>list(object({<br/>    label = string<br/>    taint = string<br/>    count = number<br/>  }))</pre> | `[]` | no |

## Outputs

| Name | Description |
| ---- | ----------- |
| <a name="output_cluster_ca_certificate"></a> [cluster\_ca\_certificate](#output\_cluster\_ca\_certificate) | GKE cluster CA certificate |
| <a name="output_host"></a> [host](#output\_host) | GKE cluster host (endpoint) |
| <a name="output_token"></a> [token](#output\_token) | GKE cluster auth token |
<!-- END_TF_DOCS -->
