variable "name" {
  description = "The name of the traefik release"
  type        = string
  default     = "traefik"
}

variable "namespace" {
  description = "Namespace for the Traefik Hub deployment"
  type        = string
}

variable "domain" {
  type        = string
  default     = ""
  description = "Base domain for ingress (e.g., benchmarks.demo.traefik.ai)"
}

variable "ingress" {
  type = object({
    enabled    = optional(bool, false)
    internal   = optional(bool, true)
    domain     = optional(string, "")
    entrypoint = optional(string, "traefik")
  })
  default     = {}
  description = "Ingress configuration for the keycloak service"
}

variable "ingress_observability" {
  type        = bool
  description = "Emit Traefik observability signals (access logs, metrics, traces) for the Keycloak ingress router. Set to false to add the three `traefik.ingress.kubernetes.io/router.observability.*: \"false\"` annotations. Same switch shape as other k8s modules."
  default     = true
}

variable "ingress_annotations" {
  type        = map(string)
  description = "Additional metadata annotations merged onto the Ingress. Useful for custom router options beyond the three observability toggles."
  default     = {}
}

variable "users" {
  description = "List of users to create in the security module"
  type        = list(string)
}

variable "redirect_uris" {
  type        = list(string)
  default     = []
  description = "Allowed callback URL for the authentication flow"
}

variable "advanced_users" {
  description = "List of advanced users with detailed configuration including groups and claims"
  type = list(object({
    username = string
    email    = string
    password = string
    groups   = list(string)
    claims   = map(list(string))
  }))
  default = []
}

variable "access_token_lifespan" {
  description = "The lifespan of the access token in seconds"
  type        = number
  default     = 2419200 # 28 days
}

variable "host" {
  type    = string
  default = ""
}

variable "client_certificate" {
  type    = string
  default = ""
}

variable "client_key" {
  type    = string
  default = ""
}

variable "instances" {
  type        = number
  default     = 1
  description = "Number of Keycloak pods behind the shared Postgres backend. Scale when multiple independent test runs hit the OIDC endpoint in parallel."
}

variable "chart" {
  type        = string
  default     = ""
  description = "Path to the Helm chart for the Keycloak deployment. When empty, uses the git-hosted chart."
}
