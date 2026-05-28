# tools/cloudflare

Creates a single Cloudflare DNS record (A or CNAME) with optional proxying.

## Example usage

```hcl
module "dns" {
  source = "git::https://github.com/traefik/traefik-demo.git//terraform/tools/cloudflare?ref=v3.2.0"

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
|------|---------|
| cloudflare | ~> 5 |

## Providers

| Name | Source | Version |
|------|--------|---------|
| cloudflare | `cloudflare/cloudflare` | `~> 5` |

## Resources

| Name | Type |
|------|------|
| `cloudflare_dns_record.root` | resource |
| `cloudflare_dns_record.wildcard` | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| domain | Domain for the Cloudflare DNS record | `string` | n/a | yes |
| zone_id | The zone ID of the Cloudflare DNS record | `string` | n/a | yes |
| hostname | Hostname for the Cloudflare DNS record | `string` | `""` | no |
| ip | IP address for the Cloudflare DNS record | `string` | `""` | no |
| proxied | Whether the record is proxied through Cloudflare | `bool` | `false` | no |
| record_type | Type of the Cloudflare DNS record | `string` | `"A"` | no |

<!-- END_TF_DOCS -->
