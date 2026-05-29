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
| ---- | ------- |
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.3 |
| <a name="requirement_nutanix"></a> [nutanix](#requirement\_nutanix) | >= 2.4.0 |

## Providers

| Name | Version |
| ---- | ------- |
| <a name="provider_nutanix"></a> [nutanix](#provider\_nutanix) | >= 2.4.0 |
| <a name="provider_terraform"></a> [terraform](#provider\_terraform) | n/a |

## Resources

| Name | Type |
| ---- | ---- |
| [nutanix_image.whoami](https://registry.terraform.io/providers/nutanix/nutanix/latest/docs/resources/image) | resource |
| [terraform_data.build_image](https://registry.terraform.io/providers/hashicorp/terraform/latest/docs/resources/data) | resource |

## Inputs

| Name | Description | Type | Default | Required |
| ---- | ----------- | ---- | ------- | :------: |
| <a name="input_arch"></a> [arch](#input\_arch) | Architecture for the image build (amd64 or arm64) | `string` | `"amd64"` | no |
| <a name="input_image_path"></a> [image\_path](#input\_image\_path) | Optional path to a pre-existing image file (skips building but still uploads) | `string` | `null` | no |

## Outputs

| Name | Description |
| ---- | ----------- |
| <a name="output_id"></a> [id](#output\_id) | Id. |
<!-- END_TF_DOCS -->
