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
|------|---------|
| nutanix | >= 2.4.0 |

## Providers

| Name | Source | Version |
|------|--------|---------|
| nutanix | `nutanix/nutanix` | `>= 2.4.0` |

## Resources

| Name | Type |
|------|------|
| `nutanix_category_key.category_key` | resource |
| `nutanix_category_value.category_value` | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| categories | Map of category keys to create with their values | `map(object({name = string, description = string, values = list(string)))` | n/a | yes |

<!-- END_TF_DOCS -->
