variable "name" {
  type        = string
  description = "The name of the oracle-db StatefulSet and Service"
  default     = "oracledb"
}

variable "namespace" {
  type        = string
  description = "The namespace of the oracle-db StatefulSet and Service"
}

variable "replicas" {
  type    = number
  default = 1
}

variable "storage_size" {
  type    = string
  default = "50Gi"
}

variable "image" {
  type    = string
  default = "container-registry.oracle.com/database/free:latest"
}

variable "service_port" {
  type    = number
  default = 1521
}

variable "container_port" {
  type    = number
  default = 1521
}

variable "oracle_pwd" {
  type        = string
  default     = "topSecretpa33word"
  description = "Oracle database password."
}

variable "oracle_characterset" {
  type        = string
  default     = "AL32UTF8"
  description = "Oracle database character set."
}

variable "ingress" {
  type        = bool
  default     = false
  description = "Enable Ingress for the oracle-db service"
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
  description = "Emit Traefik observability signals (access logs, metrics, traces) for the Oracle 23ai ingress router. Set to false to add the three `traefik.ingress.kubernetes.io/router.observability.*: \"false\"` annotations. Same switch shape as other k8s modules."
  default     = true
}

variable "ingress_annotations" {
  type        = map(string)
  description = "Additional metadata annotations merged onto the Ingress. Useful for custom router options beyond the three observability toggles."
  default     = {}
}
