# compute/nutanix/nkp

Provisions a Nutanix Kubernetes Platform (NKP) cluster end-to-end: bastion VM, control plane VIP, optional FIP, Kommander, and kubeconfig extraction.

## Example usage

```hcl
module "nkp" {
  source = "git::https://github.com/traefik/traefik-demo.git//terraform/compute/nutanix/nkp?ref=v4.0.0"

  cluster_name                       = "demo"
  nutanix_cluster_id                 = var.cluster_uuid
  nutanix_prism_element_cluster_name = "PE-01"
  nutanix_endpoint                   = var.prism_central
  nutanix_username                   = var.nutanix_username
  nutanix_password                   = var.nutanix_password
  bastion_subnet_uuid                = var.bastion_subnet_uuid
  external_subnet_uuid               = var.external_subnet_uuid
  cluster_subnets                    = [var.cluster_subnet_uuid]
  vpc_uuid                           = var.vpc_uuid
  control_plane_vip                  = "10.0.0.10"
  lb_ip_range                        = "10.0.0.20-10.0.0.30"
  nkp_image_name                     = "nkp-2.17.1"
  nkp_image_uuid                     = var.nkp_image_uuid
}
```

## Prerequisites

- A reachable Nutanix Prism Central endpoint and credentials.
- An NKP OS image already uploaded to Prism Central.
- NKP CLI/bundle available locally (used by the bastion VM provisioner).

## Notes

- The bastion VM default password (`topsecretpassword`) is also a demo value — override it for non-throwaway clusters.

<!-- BEGIN_TF_DOCS -->


## Requirements

| Name | Version |
| ---- | ------- |
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.3 |
| <a name="requirement_external"></a> [external](#requirement\_external) | ~> 2.0 |
| <a name="requirement_null"></a> [null](#requirement\_null) | ~> 3.0 |
| <a name="requirement_nutanix"></a> [nutanix](#requirement\_nutanix) | >= 2.4.0 |

## Providers

| Name | Version |
| ---- | ------- |
| <a name="provider_external"></a> [external](#provider\_external) | ~> 2.0 |
| <a name="provider_null"></a> [null](#provider\_null) | ~> 3.0 |
| <a name="provider_nutanix"></a> [nutanix](#provider\_nutanix) | >= 2.4.0 |

## Resources

| Name | Type |
| ---- | ---- |
| [null_resource.nkp_create_cluster](https://registry.terraform.io/providers/hashicorp/null/latest/docs/resources/resource) | resource |
| [null_resource.update_kubeconfig](https://registry.terraform.io/providers/hashicorp/null/latest/docs/resources/resource) | resource |
| [nutanix_floating_ip_v2.bastion_fip](https://registry.terraform.io/providers/nutanix/nutanix/latest/docs/resources/floating_ip_v2) | resource |
| [nutanix_floating_ip_v2.lb_fip](https://registry.terraform.io/providers/nutanix/nutanix/latest/docs/resources/floating_ip_v2) | resource |
| [nutanix_virtual_machine.bastion_vm](https://registry.terraform.io/providers/nutanix/nutanix/latest/docs/resources/virtual_machine) | resource |

## Inputs

| Name | Description | Type | Default | Required |
| ---- | ----------- | ---- | ------- | :------: |
| <a name="input_bastion_subnet_uuid"></a> [bastion\_subnet\_uuid](#input\_bastion\_subnet\_uuid) | Subnet UUID for the Bastion VM | `string` | n/a | yes |
| <a name="input_cluster_name"></a> [cluster\_name](#input\_cluster\_name) | Name of the NKP cluster | `string` | n/a | yes |
| <a name="input_cluster_subnets"></a> [cluster\_subnets](#input\_cluster\_subnets) | List of Subnet Names or UUIDs for the NKP nodes | `list(string)` | n/a | yes |
| <a name="input_control_plane_vip"></a> [control\_plane\_vip](#input\_control\_plane\_vip) | Control Plane VIP | `string` | n/a | yes |
| <a name="input_external_subnet_uuid"></a> [external\_subnet\_uuid](#input\_external\_subnet\_uuid) | UUID of the External Subnet for Floating IP | `string` | n/a | yes |
| <a name="input_lb_ip_range"></a> [lb\_ip\_range](#input\_lb\_ip\_range) | Load Balancer IP Range | `string` | n/a | yes |
| <a name="input_nkp_image_name"></a> [nkp\_image\_name](#input\_nkp\_image\_name) | Name of the NKP OS Image | `string` | n/a | yes |
| <a name="input_nkp_image_uuid"></a> [nkp\_image\_uuid](#input\_nkp\_image\_uuid) | UUID of the NKP OS Image | `string` | n/a | yes |
| <a name="input_nutanix_cluster_id"></a> [nutanix\_cluster\_id](#input\_nutanix\_cluster\_id) | Nutanix Cluster UUID | `string` | n/a | yes |
| <a name="input_nutanix_endpoint"></a> [nutanix\_endpoint](#input\_nutanix\_endpoint) | Nutanix Endpoint (Prism Central IP) | `string` | n/a | yes |
| <a name="input_nutanix_password"></a> [nutanix\_password](#input\_nutanix\_password) | Nutanix Password | `string` | n/a | yes |
| <a name="input_nutanix_prism_element_cluster_name"></a> [nutanix\_prism\_element\_cluster\_name](#input\_nutanix\_prism\_element\_cluster\_name) | Nutanix Prism Element Cluster Name (for NKP configuration) | `string` | n/a | yes |
| <a name="input_nutanix_username"></a> [nutanix\_username](#input\_nutanix\_username) | Nutanix Username | `string` | n/a | yes |
| <a name="input_vpc_uuid"></a> [vpc\_uuid](#input\_vpc\_uuid) | UUID of the VPC where the NKP cluster is deployed | `string` | n/a | yes |
| <a name="input_bastion_image_name"></a> [bastion\_image\_name](#input\_bastion\_image\_name) | Name of the image to use for bastion if already exists or to create | `string` | `"nkp-bastion-image"` | no |
| <a name="input_bastion_vm_password"></a> [bastion\_vm\_password](#input\_bastion\_vm\_password) | Password for the Bastion VM. DEMO DEFAULT — override per environment. | `string` | `"topsecretpassword"` | no |
| <a name="input_bastion_vm_username"></a> [bastion\_vm\_username](#input\_bastion\_vm\_username) | Username for the Bastion VM | `string` | `"traefiker"` | no |
| <a name="input_control_plane_fip"></a> [control\_plane\_fip](#input\_control\_plane\_fip) | Control Plane FIP | `string` | `""` | no |
| <a name="input_control_plane_memory_mib"></a> [control\_plane\_memory\_mib](#input\_control\_plane\_memory\_mib) | Memory in MiB for Control Plane Nodes | `number` | `65536` | no |
| <a name="input_control_plane_replicas"></a> [control\_plane\_replicas](#input\_control\_plane\_replicas) | Number of Control Plane Nodes | `number` | `3` | no |
| <a name="input_control_plane_vcpus"></a> [control\_plane\_vcpus](#input\_control\_plane\_vcpus) | vCPUs for Control Plane Nodes | `number` | `32` | no |
| <a name="input_enable_kommander_traefik_fip"></a> [enable\_kommander\_traefik\_fip](#input\_enable\_kommander\_traefik\_fip) | Enable Load Balancer FIP creation | `bool` | `false` | no |
| <a name="input_kubernetes_version"></a> [kubernetes\_version](#input\_kubernetes\_version) | Kubernetes Version | `string` | `""` | no |
| <a name="input_nkp_version"></a> [nkp\_version](#input\_nkp\_version) | NKP Version | `string` | `"2.17.1"` | no |
| <a name="input_nutanix_insecure"></a> [nutanix\_insecure](#input\_nutanix\_insecure) | Allow insecure connection to Nutanix | `bool` | `true` | no |
| <a name="input_nutanix_port"></a> [nutanix\_port](#input\_nutanix\_port) | Nutanix Port | `number` | `9440` | no |
| <a name="input_registry_mirror_url"></a> [registry\_mirror\_url](#input\_registry\_mirror\_url) | Registry Mirror URL | `string` | `""` | no |
| <a name="input_storage_container"></a> [storage\_container](#input\_storage\_container) | Nutanix Storage Container Name | `string` | `"Default"` | no |
| <a name="input_update_kubeconfig"></a> [update\_kubeconfig](#input\_update\_kubeconfig) | Update local kubeconfig with cluster context | `bool` | `true` | no |
| <a name="input_worker_memory_mib"></a> [worker\_memory\_mib](#input\_worker\_memory\_mib) | Memory in MiB for Worker Nodes | `number` | `65536` | no |
| <a name="input_worker_replicas"></a> [worker\_replicas](#input\_worker\_replicas) | Number of Worker Nodes | `number` | `4` | no |
| <a name="input_worker_vcpus"></a> [worker\_vcpus](#input\_worker\_vcpus) | vCPUs for Worker Nodes | `number` | `32` | no |

## Outputs

| Name | Description |
| ---- | ----------- |
| <a name="output_client_certificate_data"></a> [client\_certificate\_data](#output\_client\_certificate\_data) | Client certificate data |
| <a name="output_client_key_data"></a> [client\_key\_data](#output\_client\_key\_data) | Client key data |
| <a name="output_host"></a> [host](#output\_host) | Kubernetes API Server endpoint |
| <a name="output_kommander_password"></a> [kommander\_password](#output\_kommander\_password) | Kommander Dashboard Admin Password |
| <a name="output_kommander_username"></a> [kommander\_username](#output\_kommander\_username) | Kommander Dashboard Admin Username |
| <a name="output_kubeconfig"></a> [kubeconfig](#output\_kubeconfig) | Kubeconfig content for the cluster |
| <a name="output_traefik_fip"></a> [traefik\_fip](#output\_traefik\_fip) | Map of Private IP to Public IP for Load Balancer FIPs |
<!-- END_TF_DOCS -->
