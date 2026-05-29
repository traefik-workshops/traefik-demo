# apps/whoami/cloud-init

> **Status:** stub module. Intentionally minimal; expand only if a demo needs it. Documented at this minimum scope rather than removed because demo wrappers reference it.

Renders a cloud-init template that installs and starts the Traefik `whoami` binary at a configurable version, architecture, and port. No resources — output-only.

## Example usage

```hcl
module "whoami_cloud_init" {
  source = "git::https://github.com/traefik/traefik-demo.git//terraform/apps/whoami/cloud-init?ref=v4.0.0"

  whoami_version = "v1.10.1"
  arch           = "amd64"
  port           = 80
}
```

## Prerequisites

- Consumer module that accepts cloud-init user data (e.g., `compute/aws/ec2`, `compute/nutanix/vm`).

## Notes

- Stub module. Kept intentionally minimal because demo wrappers reference it; expand only if a demo needs more.

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
| <a name="input_arch"></a> [arch](#input\_arch) | The architecture (amd64, arm64) | `string` | `"amd64"` | no |
| <a name="input_port"></a> [port](#input\_port) | Port for whoami to listen on | `number` | `80` | no |
| <a name="input_whoami_version"></a> [whoami\_version](#input\_whoami\_version) | The Whoami version to install | `string` | `"v1.10.1"` | no |

## Outputs

| Name | Description |
| ---- | ----------- |
| <a name="output_rendered"></a> [rendered](#output\_rendered) | Rendered. |
<!-- END_TF_DOCS -->
