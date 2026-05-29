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
| [nutanix_image.nkp_registry](https://registry.terraform.io/providers/nutanix/nutanix/latest/docs/resources/image) | resource |
| [terraform_data.build_registry_image](https://registry.terraform.io/providers/hashicorp/terraform/latest/docs/resources/data) | resource |

## Inputs

| Name | Description | Type | Default | Required |
| ---- | ----------- | ---- | ------- | :------: |
| <a name="input_nkp_bundle_path"></a> [nkp\_bundle\_path](#input\_nkp\_bundle\_path) | Absolute or `~`-prefixed path to the NKP airgap bundle tarball. The build step extracts the `nkp` CLI and feeds the bundle to Packer to assemble the registry qcow2. | `string` | `""` | no |
| <a name="input_nkp_version"></a> [nkp\_version](#input\_nkp\_version) | Nutanix Kubernetes Platform release version embedded in the registry image (e.g. `2.17.1`). Used by Packer to pull the matching `nkp` CLI out of the bundle tarball. | `string` | `"2.17.1"` | no |

## Outputs

| Name | Description |
| ---- | ----------- |
| <a name="output_image_name"></a> [image\_name](#output\_image\_name) | Image name. |
<!-- END_TF_DOCS -->
