# tools/cloudflare

Creates a single Cloudflare DNS record (A or CNAME) with optional proxying.

## Example usage

```hcl
module "dns" {
  source = "git::https://github.com/traefik/traefik-demo.git//terraform/tools/cloudflare?ref=v4.0.0"

  zone_id     = var.cf_zone_id
  domain      = "demo.traefik.ai"
  record_type = "A"
  ip          = "203.0.113.10"
}
```

## Prerequisites

- A Cloudflare API token (`CLOUDFLARE_API_TOKEN`) with DNS edit permissions on the target zone.

<!-- BEGIN_TF_DOCS -->


## Requirements

| Name | Version |
| ---- | ------- |
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.3 |
| <a name="requirement_cloudflare"></a> [cloudflare](#requirement\_cloudflare) | ~> 5 |

## Providers

| Name | Version |
| ---- | ------- |
| <a name="provider_cloudflare"></a> [cloudflare](#provider\_cloudflare) | ~> 5 |

## Resources

| Name | Type |
| ---- | ---- |
| [cloudflare_dns_record.root](https://registry.terraform.io/providers/cloudflare/cloudflare/latest/docs/resources/dns_record) | resource |
| [cloudflare_dns_record.wildcard](https://registry.terraform.io/providers/cloudflare/cloudflare/latest/docs/resources/dns_record) | resource |

## Inputs

| Name | Description | Type | Default | Required |
| ---- | ----------- | ---- | ------- | :------: |
| <a name="input_domain"></a> [domain](#input\_domain) | Domain for the Cloudflare DNS record | `string` | n/a | yes |
| <a name="input_zone_id"></a> [zone\_id](#input\_zone\_id) | The zone ID of the Cloudflare DNS record | `string` | n/a | yes |
| <a name="input_hostname"></a> [hostname](#input\_hostname) | Hostname for the Cloudflare DNS record | `string` | `""` | no |
| <a name="input_ip"></a> [ip](#input\_ip) | IP address for the Cloudflare DNS record | `string` | `""` | no |
| <a name="input_proxied"></a> [proxied](#input\_proxied) | Whether the record is proxied through Cloudflare | `bool` | `false` | no |
| <a name="input_record_type"></a> [record\_type](#input\_record\_type) | Type of the Cloudflare DNS record | `string` | `"A"` | no |

## Outputs

No outputs.
<!-- END_TF_DOCS -->
