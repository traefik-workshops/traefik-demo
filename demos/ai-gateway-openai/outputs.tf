output "gateway_url" {
  description = "AI gateway chat-completions endpoint (k3d maps :80 to localhost)."
  value       = "http://ai.${var.domain}/v1/chat/completions"
}

output "scenarios_hint" {
  description = "How to exercise the guards."
  value       = "Run ./scenarios.sh — content-guard rejections happen at the gateway, so they pass without a real key."
}
