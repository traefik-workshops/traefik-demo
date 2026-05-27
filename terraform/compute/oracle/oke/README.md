# compute/oracle/oke

Provisions an Oracle Kubernetes Engine (OKE) cluster with optional extra node pools.

## Example usage

```hcl
module "oke" {
  source = "git::https://github.com/traefik/terraform-demo-modules.git//terraform/compute/oracle/oke?ref=v3.2.0"

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
|------|---------|
| oci | ~> 7.0 |
| tls | ~> 4.0 |

## Providers

| Name | Source | Version |
|------|--------|---------|
| oci | `oracle/oci` | `~> 7.0` |
| tls | `hashicorp/tls` | `~> 4.0` |

## Resources

| Name | Type |
|------|------|
| `tls_private_key.traefik_demo` | resource |
| `oci_core_vcn.traefik_demo` | resource |
| `oci_core_internet_gateway.traefik_demo` | resource |
| `oci_core_route_table.traefik_demo` | resource |
| `oci_core_security_list.traefik_demo` | resource |
| `oci_core_subnet.traefik_demo_endpoint` | resource |
| `oci_core_subnet.traefik_demo_nodes` | resource |
| `oci_core_subnet.traefik_demo_lb` | resource |
| `oci_containerengine_cluster.traefik_demo` | resource |
| `oci_containerengine_node_pool.traefik_demo` | resource |
| `oci_containerengine_node_pool.worker` | resource |
| `null_resource.oke_taints` | resource |
| `null_resource.oke_cluster` | resource |
| `helm_release.metrics_server` | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| cluster_name | OKE cluster name. | `string` | n/a | yes |
| cluster_location | OKE cluster location. | `string` | `"us-chicago-1"` | no |
| cluster_node_count | Number of nodes for the cluster. | `number` | `1` | no |
| cluster_node_type | Default machine type for cluster | `string` | `"VM.Standard.E4.Flex"` | no |
| compartment_id | Oracle Cloud compartment ID. | `string` | `"ocid1.compartment.oc1..aaaaaaaa5lzebpklmesa7hqpi5242wdiqhhe5tjnha44ccxzcj4coekjpjvq"` | no |
| oke_version | OKE cluster version. | `string` | `"v1.33.1"` | no |
| update_kubeconfig | Update kubeconfig after cluster creation | `bool` | `true` | no |
| worker_nodes | Worker node pool definitions. Each entry creates a dedicated node pool with the given label and taint. Note: OKE does not support native taints; they are applied via kubectl post-creation. | `list(object({label = string, taint = string, count = number))` | `[]` | no |

## Outputs

| Name | Description |
|------|-------------|
| cluster_ca_certificate 🔒 | OKE cluster CA certificate |
| cluster_id 🔒 | OKE cluster ID |
| host 🔒 | OKE cluster host |
| kubeconfig 🔒 | OKE cluster kubeconfig |
| node_pool_id 🔒 | OKE node pool ID |
| token 🔒 | OKE cluster auth token |

<!-- END_TF_DOCS -->
