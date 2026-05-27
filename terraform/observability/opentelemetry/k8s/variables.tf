variable "name" {
  type        = string
  description = "The name of the opentelemetry release"
  default     = "opentelemetry"
}

variable "namespace" {
  type        = string
  description = "The namespace of the opentelemetry release"
  default     = "traefik-observability"
}

variable "enable_prometheus" {
  type        = bool
  description = "Enable Prometheus observability module"
  default     = false
}

variable "prometheus_port" {
  type        = number
  description = "Prometheus port"
  default     = 8889
}

variable "enable_loki" {
  type        = bool
  description = "Enable Grafana Loki observability module"
  default     = false
}

variable "loki_endpoint" {
  type        = string
  description = "Loki endpoint"
  default     = ""
}

variable "enable_tempo" {
  type        = bool
  description = "Enable Grafana Tempo observability module"
  default     = false
}

variable "tempo_endpoint" {
  type        = string
  description = "Tempo endpoint"
  default     = ""
}

variable "enable_new_relic" {
  type        = bool
  description = "Enable New Relic observability module"
  default     = false
}

variable "newrelic_endpoint" {
  type        = string
  description = "New Relic endpoint"
  default     = ""
}

variable "newrelic_license_key" {
  type        = string
  description = "New Relic license key"
  default     = ""
}

variable "enable_dash0" {
  type        = bool
  description = "Enable Dash0 observability module"
  default     = false
}

variable "dash0_endpoint" {
  type        = string
  description = "Dash0 endpoint"
  default     = ""
}

variable "dash0_auth_token" {
  type        = string
  description = "Dash0 auth token"
  sensitive   = true
  default     = ""
}

variable "dash0_dataset" {
  type        = string
  description = "Dash0 dataset"
  default     = ""
}

variable "enable_honeycomb" {
  type        = bool
  description = "Enable Honeycomb observability module"
  default     = false
}

variable "honeycomb_endpoint" {
  type        = string
  description = "Honeycomb endpoint"
  default     = ""
}

variable "honeycomb_api_key" {
  type        = string
  description = "Honeycomb API key"
  sensitive   = true
  default     = ""
}

variable "honeycomb_dataset" {
  type        = string
  description = "Honeycomb dataset"
  default     = ""
}

variable "enable_langsmith" {
  type        = bool
  description = "Enable LangSmith trace export. LangSmith's OTLP endpoint ingests traces only — metrics and logs are not accepted and will not be exported there."
  default     = false
}

variable "langsmith_endpoint" {
  type        = string
  description = "LangSmith OTLP endpoint. Use https://api.smith.langchain.com/otel (US), https://eu.api.smith.langchain.com/otel (EU), or https://<self-hosted>/api/v1/otel."
  default     = "https://api.smith.langchain.com/otel"
}

variable "langsmith_api_key" {
  type        = string
  description = "LangSmith API key"
  sensitive   = true
  default     = ""
}

variable "langsmith_project" {
  type        = string
  description = "LangSmith project name. All traces from this collector land in this project unless overridden per-span via the Langsmith-Project header."
  default     = "default"
}

variable "enable_langfuse" {
  type        = bool
  description = "Enable Langfuse trace export (SaaS cloud.langfuse.com or self-hosted). Langfuse's OTLP endpoint currently accepts traces only (metrics/logs in preview); we only wire the traces pipeline here."
  default     = false
}

variable "langfuse_endpoint" {
  type        = string
  description = "Langfuse OTLP base URL. SaaS US: https://us.cloud.langfuse.com/api/public/otel. EU: https://cloud.langfuse.com/api/public/otel. Self-hosted: https://<host>/api/public/otel."
  default     = "https://us.cloud.langfuse.com/api/public/otel"
}

variable "langfuse_public_key" {
  type        = string
  description = "Langfuse public key (pk-lf-...). Pairs with langfuse_secret_key as HTTP Basic auth."
  sensitive   = true
  default     = ""
}

variable "langfuse_secret_key" {
  type        = string
  description = "Langfuse secret key (sk-lf-...). Pairs with langfuse_public_key as HTTP Basic auth."
  sensitive   = true
  default     = ""
}

variable "ingress" {
  type        = bool
  description = "Enable Ingress for the OpenTelemetry deployment."
  default     = false
}

variable "ingress_domain" {
  type        = string
  default     = "cloud"
  description = "The domain for the ingress, default is `cloud`"
}

variable "ingress_entrypoint" {
  type        = string
  default     = "traefik"
  description = "The entrypoint to use for the ingress, default is `traefik`"
}

variable "ingress_observability" {
  type        = bool
  description = "Emit Traefik observability signals (access logs, metrics, traces) for the OTLP collector router. Default is false because tracing the collector's own ingest endpoint creates an obvious feedback loop. Same switch shape as observability/langfuse/k8s."
  default     = false
}

variable "ingress_annotations" {
  type        = map(string)
  description = "Additional metadata annotations merged onto the Ingress. Useful for custom router options beyond the three observability toggles."
  default     = {}
}
