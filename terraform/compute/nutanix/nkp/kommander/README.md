# compute/nutanix/nkp/kommander

Provisions a Floating IP for the Kommander/Traefik LoadBalancer service on an NKP cluster and wires the in-cluster `LoadBalancer` Service to it.

## Example usage

```hcl
module "kommander" {
  source = "git::https://github.com/traefik/traefik-demo.git//terraform/compute/nutanix/nkp/kommander?ref=v3.2.0"

  external_subnet_uuid = var.external_subnet_uuid
  vpc_uuid             = var.vpc_uuid
}
```

## Prerequisites

- A working NKP cluster (see `compute/nutanix/nkp`).
- `kubernetes` and `kubectl` providers configured against the NKP cluster.

## Notes

<!-- BEGIN_TF_DOCS -->

## Requirements

| Name | Version |
|------|---------|
| kubernetes | (unpinned) |
| kubectl | >= 1.14 |

## Providers

| Name | Source | Version |
|------|--------|---------|
| kubernetes | `hashicorp/kubernetes` | `(unpinned)` |
| kubectl | `gavinbunney/kubectl` | `>= 1.14` |

## Resources

| Name | Type |
|------|------|
| `kubectl_manifest.traefik_overrides` | resource |
| `kubectl_manifest.traefik_app_deployment` | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| external_subnet_uuid | UUID of the external subnet for FIP creation | `string` | n/a | yes |
| vpc_uuid | UUID of the VPC | `string` | n/a | yes |

<!-- END_TF_DOCS -->
