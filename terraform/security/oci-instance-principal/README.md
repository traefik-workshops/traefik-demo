# security/oci-instance-principal

Creates an OCI dynamic group and policy so instances in a compartment can authenticate as instance principals (no static API keys).

## Example usage

```hcl
module "oci_instance_principal" {
  source = "git::https://github.com/traefik/traefik-demo.git//terraform/security/oci-instance-principal?ref=v4.0.0"

  compartment_id = var.compartment_id
}
```

## Prerequisites

- OCI credentials with IAM (dynamic group + policy) permissions.

<!-- BEGIN_TF_DOCS -->


## Requirements

| Name | Version |
| ---- | ------- |
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.3 |
| <a name="requirement_oci"></a> [oci](#requirement\_oci) | ~> 7.0 |

## Providers

| Name | Version |
| ---- | ------- |
| <a name="provider_oci"></a> [oci](#provider\_oci) | ~> 7.0 |

## Resources

| Name | Type |
| ---- | ---- |
| [oci_identity_dynamic_group.traefik_instance_principals_dynamic_group](https://registry.terraform.io/providers/oracle/oci/latest/docs/resources/identity_dynamic_group) | resource |
| [oci_identity_policy.traefik_instance_principals_policy](https://registry.terraform.io/providers/oracle/oci/latest/docs/resources/identity_policy) | resource |

## Inputs

| Name | Description | Type | Default | Required |
| ---- | ----------- | ---- | ------- | :------: |
| <a name="input_compartment_id"></a> [compartment\_id](#input\_compartment\_id) | The OCID of the compartment | `string` | n/a | yes |

## Outputs

No outputs.
<!-- END_TF_DOCS -->
