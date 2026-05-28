output "public_key" {
  description = "Seeded Langfuse public API key (pk-lf-…). Wire into the OTel Collector's langfuse exporter."
  value       = local.public_key
  sensitive   = true
}

output "secret_key" {
  description = "Seeded Langfuse secret API key (sk-lf-…)."
  value       = local.secret_key
  sensitive   = true
}

output "otel_endpoint" {
  description = "In-cluster OTLP base URL. Append nothing — the OTel exporter handles /v1/traces itself."
  value       = local.otel_endpoint
}

output "web_service_name" {
  description = "Service name of the langfuse-web component. Pair with `namespace` to build in-cluster DNS."
  value       = local.web_service_name
}

output "admin_user_email" {
  description = "Email of the seeded admin user — UI login."
  value       = var.init_user_email
}

output "admin_user_password" {
  description = "Password of the seeded admin user — UI login."
  value       = var.init_user_password
  sensitive   = true
}
