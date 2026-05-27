variable "name" {
  type        = string
  description = "The name of the open-webui release"
  default     = "open-webui"
}

variable "namespace" {
  type        = string
  description = "The namespace of the milvus release"
  default     = "milvus"
}

variable "openai_api_base_urls" {
  type        = list(string)
  default     = []
  description = "OpenAI API base URLs"
}

variable "openai_api_keys" {
  type        = list(string)
  default     = []
  description = "OpenAI API keys"
}

variable "ingress" {
  type        = bool
  default     = false
  description = "Enable ingress for the open-webui release"
}

variable "extra_values" {
  type        = any
  description = "Extra values to pass to the Grafana deployment."
  default     = {}
}

variable "ingress_domain" {
  type        = string
  default     = "cloud"
  description = "The domain for the ingress, default is `cloud`"
}

variable "ingress_entrypoint" {
  type        = string
  default     = "web"
  description = "The entrypoint to use for the ingress, default is `web`"
}

variable "ingress_observability" {
  type        = bool
  description = "Emit Traefik observability signals (access logs, metrics, traces) for the Open WebUI ingress router. Set to false to add the three `traefik.ingress.kubernetes.io/router.observability.*: \"false\"` annotations. Same switch shape as other k8s modules."
  default     = true
}

variable "ingress_annotations" {
  type        = map(string)
  description = "Additional metadata annotations merged onto the Ingress. Useful for custom router options beyond the three observability toggles."
  default     = {}
}

variable "mcp_connections" {
  type = list(object({
    type      = optional(string, "mcp")
    url       = string
    path      = optional(string, "/")
    auth_type = optional(string, "bearer")
    key       = optional(string, "")
    config    = optional(map(string), {})
    info = object({
      id          = string
      name        = string
      description = string
    })
  }))
  default     = []
  description = "MCP connections with required Open WebUI fields"
}
