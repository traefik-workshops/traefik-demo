resource "cloudflare_dns_record" "root" {
  zone_id = var.zone_id
  name    = var.domain
  content = var.record_type == "A" ? var.ip : var.hostname
  type    = var.record_type
  ttl     = 1
  proxied = var.proxied
}

resource "cloudflare_dns_record" "wildcard" {
  zone_id = var.zone_id
  name    = "*.${var.domain}"
  content = var.record_type == "A" ? var.ip : var.hostname
  type    = var.record_type
  ttl     = 1
  proxied = var.proxied
}
