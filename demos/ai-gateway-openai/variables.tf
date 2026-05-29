variable "cluster_name" {
  type        = string
  description = "k3d cluster name."
  default     = "ai-gateway-openai"
}

variable "domain" {
  type        = string
  description = "Domain the gateway is exposed on. With k3d this resolves to localhost, so any *.localhost works."
  default     = "ai-gateway-openai.localhost"
}

variable "traefik_hub_token" {
  type        = string
  description = "Traefik Hub license token (offline JWT) — required for the AI gateway. Get one at https://hub.traefik.io."
  sensitive   = true
}

variable "openai_api_key" {
  type        = string
  description = "Key the chat-completion middleware injects as the upstream Authorization header. The content-guard scenarios block at the gateway and never reach the backend, so they pass with a placeholder; only the happy-path scenario needs a real key (or a mock backend)."
  default     = "sk-REPLACE_ME"
  sensitive   = true
}

variable "backend_external_name" {
  type        = string
  description = "Upstream the gateway forwards to (OpenAI-compatible). Point at a mock for a fully keyless run."
  default     = "api.openai.com"
}

variable "token_limit" {
  type        = number
  description = "Token budget for the ai-rate-limit middleware (total_tokens over the period)."
  default     = 100000
}
