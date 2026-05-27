variable "name" {
  type        = string
  description = "The name of the sqlcl-mcp Deployment and Service"
  default     = "sqlcl-mcp"
}

variable "namespace" {
  type        = string
  description = "The namespace of the sqlcl-mcp Deployment and Service"
}

variable "replicas" {
  type    = number
  default = 1
}

variable "image" {
  type    = string
  default = "zalbiraw/sqlcl:latest"
}

variable "service_port" {
  type    = number
  default = 8096
}

variable "container_port" {
  type    = number
  default = 8096
}

variable "ingress" {
  type        = bool
  default     = false
  description = "Enable Ingress for the sqlcl-mcp service"
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
  description = "Emit Traefik observability signals (access logs, metrics, traces) for the SQLcl MCP ingress router. Set to false to add the three `traefik.ingress.kubernetes.io/router.observability.*: \"false\"` annotations. Same switch shape as other k8s modules."
  default     = true
}

variable "ingress_annotations" {
  type        = map(string)
  description = "Additional metadata annotations merged onto the Ingress. Useful for custom router options beyond the three observability toggles."
  default     = {}
}
