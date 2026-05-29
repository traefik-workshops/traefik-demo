# apps/whoami/nutanix

Provisions a Traefik `whoami` VM on Nutanix AHV via `compute/nutanix/vm`, with cloud-init and Prism Central category-based service discovery.

## Example usage

```hcl
module "whoami_nutanix" {
  source = "git::https://github.com/traefik/traefik-demo.git//terraform/apps/whoami/nutanix?ref=v4.0.0"

  vm_name     = "whoami-01"
  cluster_id  = var.nutanix_cluster_uuid
  subnet_uuid = var.subnet_uuid
  image_id    = module.whoami_image.id
}
```

## Prerequisites

- A reachable Nutanix Prism Central endpoint and credentials.
- A pre-built whoami image (see `apps/whoami/nutanix/image_builder`).

<!-- BEGIN_TF_DOCS -->


## Requirements

| Name | Version |
| ---- | ------- |
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.3 |

## Providers

No providers.

## Resources

No resources.

## Inputs

| Name | Description | Type | Default | Required |
| ---- | ----------- | ---- | ------- | :------: |
| <a name="input_cluster_id"></a> [cluster\_id](#input\_cluster\_id) | UUID of the Nutanix Cluster | `string` | n/a | yes |
| <a name="input_image_id"></a> [image\_id](#input\_image\_id) | UUID of the Image to use | `string` | n/a | yes |
| <a name="input_subnet_uuid"></a> [subnet\_uuid](#input\_subnet\_uuid) | UUID of the Subnet | `string` | n/a | yes |
| <a name="input_vm_name"></a> [vm\_name](#input\_vm\_name) | Name of the VM | `string` | n/a | yes |
| <a name="input_arch"></a> [arch](#input\_arch) | Architecture of the VM | `string` | `"amd64"` | no |
| <a name="input_load_balancer_strategy"></a> [load\_balancer\_strategy](#input\_load\_balancer\_strategy) | Load balancer strategy for Nutanix Prism Central discovery (TraefikLoadBalancerStrategy category) | `string` | `""` | no |
| <a name="input_service_name"></a> [service\_name](#input\_service\_name) | Service name for Nutanix Prism Central discovery (TraefikServiceName category) | `string` | `"whoami"` | no |
| <a name="input_service_port"></a> [service\_port](#input\_service\_port) | Service port for Nutanix Prism Central discovery (TraefikServicePort category) | `number` | `8080` | no |
| <a name="input_vm_memory_mib"></a> [vm\_memory\_mib](#input\_vm\_memory\_mib) | Memory size in MiB | `number` | `1024` | no |
| <a name="input_vm_num_sockets"></a> [vm\_num\_sockets](#input\_vm\_num\_sockets) | Number of sockets | `number` | `1` | no |
| <a name="input_vm_num_vcpus_per_socket"></a> [vm\_num\_vcpus\_per\_socket](#input\_vm\_num\_vcpus\_per\_socket) | Number of vCPUs per socket | `number` | `1` | no |
| <a name="input_whoami_version"></a> [whoami\_version](#input\_whoami\_version) | The Whoami version to install | `string` | `"v1.10.1"` | no |

## Outputs

| Name | Description |
| ---- | ----------- |
| <a name="output_ip_address"></a> [ip\_address](#output\_ip\_address) | Ip address. |
<!-- END_TF_DOCS -->
