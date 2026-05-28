variable "zone_id" {
  description = "The zone ID of the Cloudflare DNS record"
  type        = string
}

variable "domain" {
  description = "Domain for the Cloudflare DNS record"
  type        = string
}

variable "ip" {
  description = "IP address for the Cloudflare DNS record"
  type        = string
  default     = ""

  validation {
    condition     = var.record_type != "A" || var.ip != ""
    error_message = "IP address is required for A record"
  }
}

variable "hostname" {
  description = "Hostname for the Cloudflare DNS record"
  type        = string
  default     = ""

  validation {
    condition     = var.record_type != "CNAME" || var.hostname != ""
    error_message = "Hostname is required for CNAME record"
  }
}

variable "record_type" {
  description = "Type of the Cloudflare DNS record"
  type        = string
  default     = "A"
}

variable "proxied" {
  description = "Whether the record is proxied through Cloudflare"
  type        = bool
  default     = false
}
