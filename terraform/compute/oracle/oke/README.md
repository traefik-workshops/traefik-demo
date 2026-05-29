# compute/oracle/oke

Provisions an Oracle Kubernetes Engine (OKE) cluster with optional extra node pools.

## Example usage

```hcl
module "oke" {
  source = "git::https://github.com/traefik/traefik-demo.git//terraform/compute/oracle/oke?ref=v4.0.0"

  cluster_name     = "demo"
  cluster_location = "us-chicago-1"
  compartment_id   = var.compartment_id
}
```

## Prerequisites

- OCI credentials with OKE/VCN/IAM permissions, or use `security/oci-instance-principal`.
- `kubectl` on PATH if `update_kubeconfig = true`.

<!-- BEGIN_TF_DOCS -->


## Requirements

| Name | Version |
| ---- | ------- |
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.3 |
| <a name="requirement_external"></a> [external](#requirement\_external) | ~> 2.0 |
| <a name="requirement_helm"></a> [helm](#requirement\_helm) | ~> 3.0 |
| <a name="requirement_null"></a> [null](#requirement\_null) | ~> 3.0 |
| <a name="requirement_oci"></a> [oci](#requirement\_oci) | ~> 7.0 |
| <a name="requirement_tls"></a> [tls](#requirement\_tls) | ~> 4.0 |

## Providers

| Name | Version |
| ---- | ------- |
| <a name="provider_external"></a> [external](#provider\_external) | ~> 2.0 |
| <a name="provider_helm"></a> [helm](#provider\_helm) | ~> 3.0 |
| <a name="provider_null"></a> [null](#provider\_null) | ~> 3.0 |
| <a name="provider_oci"></a> [oci](#provider\_oci) | ~> 7.0 |
| <a name="provider_tls"></a> [tls](#provider\_tls) | ~> 4.0 |

## Resources

| Name | Type |
| ---- | ---- |
| [helm_release.metrics_server](https://registry.terraform.io/providers/hashicorp/helm/latest/docs/resources/release) | resource |
| [null_resource.oke_cluster](https://registry.terraform.io/providers/hashicorp/null/latest/docs/resources/resource) | resource |
| [null_resource.oke_taints](https://registry.terraform.io/providers/hashicorp/null/latest/docs/resources/resource) | resource |
| [oci_containerengine_cluster.traefik_demo](https://registry.terraform.io/providers/oracle/oci/latest/docs/resources/containerengine_cluster) | resource |
| [oci_containerengine_node_pool.traefik_demo](https://registry.terraform.io/providers/oracle/oci/latest/docs/resources/containerengine_node_pool) | resource |
| [oci_containerengine_node_pool.worker](https://registry.terraform.io/providers/oracle/oci/latest/docs/resources/containerengine_node_pool) | resource |
| [oci_core_internet_gateway.traefik_demo](https://registry.terraform.io/providers/oracle/oci/latest/docs/resources/core_internet_gateway) | resource |
| [oci_core_route_table.traefik_demo](https://registry.terraform.io/providers/oracle/oci/latest/docs/resources/core_route_table) | resource |
| [oci_core_security_list.traefik_demo](https://registry.terraform.io/providers/oracle/oci/latest/docs/resources/core_security_list) | resource |
| [oci_core_subnet.traefik_demo_endpoint](https://registry.terraform.io/providers/oracle/oci/latest/docs/resources/core_subnet) | resource |
| [oci_core_subnet.traefik_demo_lb](https://registry.terraform.io/providers/oracle/oci/latest/docs/resources/core_subnet) | resource |
| [oci_core_subnet.traefik_demo_nodes](https://registry.terraform.io/providers/oracle/oci/latest/docs/resources/core_subnet) | resource |
| [oci_core_vcn.traefik_demo](https://registry.terraform.io/providers/oracle/oci/latest/docs/resources/core_vcn) | resource |
| [tls_private_key.traefik_demo](https://registry.terraform.io/providers/hashicorp/tls/latest/docs/resources/private_key) | resource |

## Inputs

| Name | Description | Type | Default | Required |
| ---- | ----------- | ---- | ------- | :------: |
| <a name="input_cluster_name"></a> [cluster\_name](#input\_cluster\_name) | OKE cluster name. | `string` | n/a | yes |
| <a name="input_compartment_id"></a> [compartment\_id](#input\_compartment\_id) | Oracle Cloud compartment ID. | `string` | n/a | yes |
| <a name="input_cluster_location"></a> [cluster\_location](#input\_cluster\_location) | OKE cluster location. | `string` | `"us-chicago-1"` | no |
| <a name="input_cluster_node_count"></a> [cluster\_node\_count](#input\_cluster\_node\_count) | Number of nodes for the cluster. | `number` | `1` | no |
| <a name="input_cluster_node_type"></a> [cluster\_node\_type](#input\_cluster\_node\_type) | Default machine type for cluster | `string` | `"VM.Standard.E4.Flex"` | no |
| <a name="input_oke_version"></a> [oke\_version](#input\_oke\_version) | OKE cluster version. | `string` | `"v1.33.1"` | no |
| <a name="input_update_kubeconfig"></a> [update\_kubeconfig](#input\_update\_kubeconfig) | Update kubeconfig after cluster creation | `bool` | `true` | no |
| <a name="input_worker_nodes"></a> [worker\_nodes](#input\_worker\_nodes) | Worker node pool definitions. Each entry creates a dedicated node pool with the given label and taint. Note: OKE does not support native taints; they are applied via kubectl post-creation. | <pre>list(object({<br/>    label = string<br/>    taint = string<br/>    count = number<br/>  }))</pre> | `[]` | no |

## Outputs

| Name | Description |
| ---- | ----------- |
| <a name="output_cluster_ca_certificate"></a> [cluster\_ca\_certificate](#output\_cluster\_ca\_certificate) | OKE cluster CA certificate |
| <a name="output_cluster_id"></a> [cluster\_id](#output\_cluster\_id) | OKE cluster ID |
| <a name="output_host"></a> [host](#output\_host) | OKE cluster host |
| <a name="output_kubeconfig"></a> [kubeconfig](#output\_kubeconfig) | OKE cluster kubeconfig |
| <a name="output_node_pool_id"></a> [node\_pool\_id](#output\_node\_pool\_id) | OKE node pool ID |
| <a name="output_token"></a> [token](#output\_token) | OKE cluster auth token |
<!-- END_TF_DOCS -->
