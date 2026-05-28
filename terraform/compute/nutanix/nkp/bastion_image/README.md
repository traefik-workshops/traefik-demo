# compute/nutanix/nkp/bastion_image

Extracts the NKP bastion image from the NKP bundle and uploads it to Nutanix as a `nutanix_image`.

## Example usage

```hcl
module "nkp_bastion_image" {
  source = "git::https://github.com/traefik/traefik-demo.git//terraform/compute/nutanix/nkp/bastion_image?ref=v3.2.0"

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
| `terraform_data.build_image` | resource |
| `nutanix_image.nkp` | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| nkp_bundle_file | n/a | `string` | `""` | no |
| nkp_bundle_path | n/a | `string` | `""` | no |
| nkp_cli_path | Optional path to a pre-existing NKP CLI binary (skips extraction from bundle) | `string` | `None` | no |
| nkp_version | n/a | `string` | `"2.17.1"` | no |

<!-- END_TF_DOCS -->
