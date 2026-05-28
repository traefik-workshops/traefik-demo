# apps/whoami/nutanix/image_builder

Builds a Whoami qcow2 image with Packer (via `local-exec`) and uploads it to Nutanix as a `nutanix_image`.

## Example usage

```hcl
module "whoami_image" {
  source = "git::https://github.com/traefik/traefik-demo.git//terraform/apps/whoami/nutanix/image_builder?ref=v4.0.0"

  arch = "amd64"
}
```

## Prerequisites

- Packer installed locally and reachable on `PATH`.
- The `packer/` directory under this module (a `Makefile` with `packer-build-amd64` / `packer-build-arm64` targets).
- A reachable Nutanix Prism Central endpoint and credentials.

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
| `nutanix_image.whoami` | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| arch | Architecture for the image build (amd64 or arm64) | `string` | `"amd64"` | no |
| image_path | Optional path to a pre-existing image file (skips building but still uploads) | `string` | `None` | no |
| vm_name | Name prefix for the image | `string` | `"whoami"` | no |

## Outputs

| Name | Description |
|------|-------------|
| id | n/a |

<!-- END_TF_DOCS -->
