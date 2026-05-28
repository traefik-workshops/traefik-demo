# compute/nutanix/nkp/registry_image

Extracts the NKP registry image from the NKP bundle and uploads it to Nutanix as a `nutanix_image`.

## Example usage

```hcl
module "nkp_registry_image" {
  source = "git::https://github.com/traefik/traefik-demo.git//terraform/compute/nutanix/nkp/registry_image?ref=v4.0.0"

  nkp_version     = "2.17.1"
  nkp_bundle_path = "/path/to/nkp-bundle.tar.gz"
}
```

## Prerequisites

- A reachable Nutanix Prism Central endpoint and credentials.
- The NKP bundle archive available locally.

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
| `terraform_data.build_registry_image` | resource |
| `nutanix_image.nkp_registry` | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| nkp_bundle_file | n/a | `string` | `""` | no |
| nkp_bundle_path | n/a | `string` | `""` | no |
| nkp_version | n/a | `string` | `"2.17.1"` | no |

## Outputs

| Name | Description |
|------|-------------|
| image_name | n/a |

<!-- END_TF_DOCS -->
