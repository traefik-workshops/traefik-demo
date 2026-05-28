# compute/nutanix/nkp/registry

Provisions a self-hosted container registry VM on Nutanix for use as an NKP registry mirror.

## Example usage

```hcl
module "nkp_registry" {
  source = "git::https://github.com/traefik/traefik-demo.git//terraform/compute/nutanix/nkp/registry?ref=v4.0.0"

  cluster_name        = "demo"
  nutanix_cluster_id  = var.cluster_uuid
  subnet_uuid         = var.subnet_uuid
  registry_image_uuid = module.nkp_registry_image.id
}
```

## Prerequisites

- A reachable Nutanix Prism Central endpoint and credentials.
- An NKP registry image (see `compute/nutanix/nkp/registry_image`).

## Notes

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
| `nutanix_virtual_machine.registry_vm` | resource |
| `terraform_data.registry_health_check` | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| cluster_name | Name of the cluster to prefix the VM name | `string` | n/a | yes |
| nutanix_cluster_id | Nutanix Cluster UUID | `string` | n/a | yes |
| registry_image_uuid | UUID of the NKP Registry Image | `string` | n/a | yes |
| subnet_uuid | Subnet UUID for the Registry VM | `string` | n/a | yes |
| docker_hub_access_token 🔒 | Docker Hub Access Token | `string` | `""` | no |
| docker_hub_username | Docker Hub Username | `string` | `""` | no |
| private_ip | Optional private IP for the registry VM | `string` | `None` | no |
| public_ip | Optional public IP for the registry VM | `string` | `None` | no |

## Outputs

| Name | Description |
|------|-------------|
| registry_ip | n/a |
| registry_url | n/a |

<!-- END_TF_DOCS -->
