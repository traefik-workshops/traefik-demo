# apps/whoami/cloud-init

Renders a cloud-init template that installs and starts the Traefik `whoami` binary at a configurable version, architecture, and port. No resources — output-only.

## Example usage

```hcl
module "whoami_cloud_init" {
  source = "git::https://github.com/traefik/terraform-demo-modules.git//terraform/apps/whoami/cloud-init?ref=v3.2.0"

  whoami_version = "v1.10.1"
  arch           = "amd64"
  port           = 80
}
```

## Prerequisites

- Consumer module that accepts cloud-init user data (e.g., `compute/aws/ec2`, `compute/nutanix/vm`).

## Notes

- This module currently keeps its `variable`/`output` blocks inline in `main.tf` and has no `required_providers` — see STUB-01 and PROV-01 in [../../../ISSUES.md](../../../ISSUES.md).

<!-- BEGIN_TF_DOCS -->

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| arch | The architecture (amd64, arm64) | `string` | `"amd64"` | no |
| port | Port for whoami to listen on | `number` | `80` | no |
| whoami_version | The Whoami version to install | `string` | `"v1.10.1"` | no |

## Outputs

| Name | Description |
|------|-------------|
| rendered | n/a |

<!-- END_TF_DOCS -->
