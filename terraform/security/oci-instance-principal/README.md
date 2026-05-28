# security/oci-instance-principal

Creates an OCI dynamic group and policy so instances in a compartment can authenticate as instance principals (no static API keys).

## Example usage

```hcl
module "oci_instance_principal" {
  source = "git::https://github.com/traefik/traefik-demo.git//terraform/security/oci-instance-principal?ref=v3.2.0"

  compartment_id = var.compartment_id
}
```

## Prerequisites

- OCI credentials with IAM (dynamic group + policy) permissions.

<!-- BEGIN_TF_DOCS -->

## Requirements

| Name | Version |
|------|---------|
| oci | ~> 7.0 |

## Providers

| Name | Source | Version |
|------|--------|---------|
| oci | `oracle/oci` | `~> 7.0` |

## Resources

| Name | Type |
|------|------|
| `oci_identity_dynamic_group.traefik_instance_principals_dynamic_group` | resource |
| `oci_identity_policy.traefik_instance_principals_policy` | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| compartment_id | The OCID of the compartment | `string` | n/a | yes |

<!-- END_TF_DOCS -->
