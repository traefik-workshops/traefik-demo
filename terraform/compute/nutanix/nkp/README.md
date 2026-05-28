# compute/nutanix/nkp

Provisions a Nutanix Kubernetes Platform (NKP) cluster end-to-end: bastion VM, control plane VIP, optional FIP, Kommander, and kubeconfig extraction.

## Example usage

```hcl
module "nkp" {
  source = "git::https://github.com/traefik/traefik-demo.git//terraform/compute/nutanix/nkp?ref=v3.2.0"

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
|------|---------|
| nutanix | >= 2.4.0 |

## Providers

| Name | Source | Version |
|------|--------|---------|
| nutanix | `nutanix/nutanix` | `>= 2.4.0` |

## Resources

| Name | Type |
|------|------|
| `null_resource.update_kubeconfig` | resource |
| `nutanix_floating_ip_v2.lb_fip` | resource |
| `nutanix_virtual_machine.bastion_vm` | resource |
| `nutanix_floating_ip_v2.bastion_fip` | resource |
| `null_resource.nkp_create_cluster` | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| bastion_subnet_uuid | Subnet UUID for the Bastion VM | `string` | n/a | yes |
| cluster_name | Name of the NKP cluster | `string` | n/a | yes |
| cluster_subnets | List of Subnet Names or UUIDs for the NKP nodes | `list(string)` | n/a | yes |
| control_plane_vip | Control Plane VIP | `string` | n/a | yes |
| external_subnet_uuid | UUID of the External Subnet for Floating IP | `string` | n/a | yes |
| lb_ip_range | Load Balancer IP Range | `string` | n/a | yes |
| nkp_image_name | Name of the NKP OS Image | `string` | n/a | yes |
| nkp_image_uuid | UUID of the NKP OS Image | `string` | n/a | yes |
| nutanix_cluster_id | Nutanix Cluster UUID | `string` | n/a | yes |
| nutanix_endpoint | Nutanix Endpoint (Prism Central IP) | `string` | n/a | yes |
| nutanix_password 🔒 | Nutanix Password | `string` | n/a | yes |
| nutanix_prism_element_cluster_name | Nutanix Prism Element Cluster Name (for NKP configuration) | `string` | n/a | yes |
| nutanix_username | Nutanix Username | `string` | n/a | yes |
| vpc_uuid | UUID of the VPC where the NKP cluster is deployed | `string` | n/a | yes |
| bastion_image_name | Name of the image to use for bastion if already exists or to create | `string` | `"nkp-bastion-image"` | no |
| bastion_vm_password | Password for the Bastion VM | `string` | `"topsecretpassword"` | no |
| bastion_vm_username | Username for the Bastion VM | `string` | `"traefiker"` | no |
| control_plane_fip | Control Plane FIP | `string` | `""` | no |
| control_plane_memory_mib | Memory in MiB for Control Plane Nodes | `number` | `65536` | no |
| control_plane_replicas | Number of Control Plane Nodes | `number` | `3` | no |
| control_plane_vcpus | vCPUs for Control Plane Nodes | `number` | `32` | no |
| enable_kommander_traefik_fip | Enable Load Balancer FIP creation | `bool` | `false` | no |
| kubernetes_version | Kubernetes Version | `string` | `""` | no |
| nkp_version | NKP Version | `string` | `"2.17.1"` | no |
| nutanix_insecure | Allow insecure connection to Nutanix | `bool` | `true` | no |
| nutanix_port | Nutanix Port | `number` | `9440` | no |
| registry_mirror_url | Registry Mirror URL | `string` | `""` | no |
| storage_container | Nutanix Storage Container Name | `string` | `"Default"` | no |
| update_kubeconfig | Update local kubeconfig with cluster context | `bool` | `true` | no |
| worker_memory_mib | Memory in MiB for Worker Nodes | `number` | `65536` | no |
| worker_replicas | Number of Worker Nodes | `number` | `4` | no |
| worker_vcpus | vCPUs for Worker Nodes | `number` | `32` | no |

## Outputs

| Name | Description |
|------|-------------|
| client_certificate_data 🔒 | Client certificate data |
| client_key_data 🔒 | Client key data |
| host 🔒 | Kubernetes API Server endpoint |
| kommander_password 🔒 | Kommander Dashboard Admin Password |
| kommander_username 🔒 | Kommander Dashboard Admin Username |
| kubeconfig 🔒 | Kubeconfig content for the cluster |
| traefik_fip | Map of Private IP to Public IP for Load Balancer FIPs |

<!-- END_TF_DOCS -->
