# compute/nutanix/categories

Creates Nutanix Prism Central categories and their values from a map.

## Example usage

```hcl
module "categories" {
  source = "git::https://github.com/traefik/traefik-demo.git//terraform/compute/nutanix/categories?ref=v4.0.0"

  categories = {
    "TraefikServiceName" = {
      name        = "TraefikServiceName"
      description = "Logical service name used by Traefik discovery"
      values      = ["whoami", "httpbin"]
    }
  }
}
```

## Prerequisites

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

## Resources

| Name | Type |
| ---- | ---- |
| [nutanix_category_key.category_key](https://registry.terraform.io/providers/nutanix/nutanix/latest/docs/resources/category_key) | resource |
| [nutanix_category_value.category_value](https://registry.terraform.io/providers/nutanix/nutanix/latest/docs/resources/category_value) | resource |

## Inputs

| Name | Description | Type | Default | Required |
| ---- | ----------- | ---- | ------- | :------: |
| <a name="input_categories"></a> [categories](#input\_categories) | Map of category keys to create with their values | <pre>map(object({<br/>    name        = string<br/>    description = string<br/>    values      = list(string)<br/>  }))</pre> | n/a | yes |

## Outputs

No outputs.
<!-- END_TF_DOCS -->
