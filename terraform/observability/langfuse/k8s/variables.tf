variable "name" {
  type        = string
  description = "Name of the langfuse release."
  default     = "langfuse"
}

variable "namespace" {
  type        = string
  description = "Namespace of the langfuse release. Caller is expected to create it. Default matches the opentelemetry/k8s module so collector + langfuse can live side by side."
  default     = "traefik-observability"
}

variable "chart_version" {
  type        = string
  description = "Version of the langfuse/langfuse-k8s Helm chart."
  default     = "1.5.27"
}

variable "replicas" {
  type        = number
  description = "Replica count for langfuse web and worker deployments."
  default     = 1
}

# ── Headless bootstrap (LANGFUSE_INIT_*) ─────────────────────────────────────
# Seeds an organization, project, API keys, and an admin user the first time
# the pods boot. Makes the instance usable without clicking through the signup
# flow. Pair with disable_signup=true to lock the door afterwards.

variable "init_org_id" {
  type        = string
  description = "Identifier of the seeded organization (LANGFUSE_INIT_ORG_ID)."
  default     = "default"
}

variable "init_org_name" {
  type        = string
  description = "Display name of the seeded organization (LANGFUSE_INIT_ORG_NAME)."
  default     = "Demo"
}

variable "init_project_id" {
  type        = string
  description = "Identifier of the seeded project (LANGFUSE_INIT_PROJECT_ID)."
  default     = "default"
}

variable "init_project_name" {
  type        = string
  description = "Display name of the seeded project (LANGFUSE_INIT_PROJECT_NAME)."
  default     = "default"
}

variable "init_user_email" {
  type        = string
  description = "Email of the seeded admin user. Used to log into the UI (LANGFUSE_INIT_USER_EMAIL). Langfuse requires a valid email; the local-part is what users type as the login handle."
  default     = "admin@traefik.io"
}

variable "init_user_name" {
  type        = string
  description = "Display name of the seeded admin user (LANGFUSE_INIT_USER_NAME)."
  default     = "Admin"
}

variable "init_user_password" {
  type        = string
  description = "Password of the seeded admin user (LANGFUSE_INIT_USER_PASSWORD). Demo default; override for anything real."
  sensitive   = true
  default     = "topsecretpassword"
}

variable "disable_signup" {
  type        = bool
  description = "When true, sets AUTH_DISABLE_SIGNUP=true so no additional users can register after the seeded admin."
  default     = true
}

# ── NextAuth + crypto ─────────────────────────────────────────────────────────

variable "nextauth_secret" {
  type        = string
  description = "NEXTAUTH_SECRET (langfuse.nextauth.secret.value). Demo default — rotate for real use."
  sensitive   = true
  default     = "demo-nextauth-secret-change-me"
}

variable "salt" {
  type        = string
  description = "SALT used to hash API keys (langfuse.salt.value). Demo default — rotate for real use."
  sensitive   = true
  default     = "demo-salt-change-me"
}

variable "encryption_key" {
  type        = string
  description = "ENCRYPTION_KEY for at-rest encryption (langfuse.encryptionKey.value). 64 hex chars. Demo default is all zeros — override for real use (openssl rand -hex 32)."
  sensitive   = true
  default     = "0000000000000000000000000000000000000000000000000000000000000000"
}

# ── Bundled subcharts (postgres / redis / clickhouse / minio) ────────────────

variable "subchart_password" {
  type        = string
  description = "Shared password for the bundled Postgres, Redis, Clickhouse, and S3 (Minio) subcharts. Demo convenience."
  sensitive   = true
  default     = "langfuse"
}

# ── Ingress (IngressRoute via Traefik CRDs) ──────────────────────────────────

variable "ingress" {
  type        = bool
  description = "Create a Traefik IngressRoute on `ingress_host` pointing at the langfuse-web Service."
  default     = false
}

variable "ingress_host" {
  type        = string
  description = "Host header matched by the IngressRoute (when ingress=true)."
  default     = "langfuse.localhost"
}

variable "ingress_entrypoint" {
  type        = string
  description = "Traefik entrypoint the IngressRoute binds to."
  default     = "web"
}

variable "ingress_external_port" {
  type        = number
  description = "External port on which `ingress_host` is reachable from a browser — used only to build the NEXTAUTH_URL."
  default     = 8080
}

variable "ingress_observability" {
  type        = bool
  description = "Emit Traefik observability signals (access logs, metrics, traces) for the Langfuse UI router. Set to false to add the three `traefik.ingress.kubernetes.io/router.observability.*: \"false\"` annotations. Same switch shape as other observability/k8s modules."
  default     = true
}

variable "ingress_annotations" {
  type        = map(string)
  description = "Additional metadata annotations merged onto the IngressRoute. Useful for custom router options beyond the three observability toggles."
  default     = {}
}
