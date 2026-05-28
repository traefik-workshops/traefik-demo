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
  description = "Number of Oracle 23ai StatefulSet replicas. Default `1` is fine for demos; the chart isn't HA-aware so larger values aren't useful without external coordination."
  type        = number
  default     = 1
}

variable "storage_size" {
  description = "PersistentVolumeClaim size requested per replica for `/opt/oracle/oradata`. Default `50Gi` covers a demo dataset; bump for benchmarks."
  type        = string
  default     = "50Gi"
}

variable "image" {
  description = "Container image for the Oracle 23ai database. Defaults to the public Oracle Free image; override to pin a tag or point at a mirrored registry."
  type        = string
  default     = "container-registry.oracle.com/database/free:latest"
}

variable "service_port" {
  description = "Cluster-IP Service port that exposes the Oracle TNS listener. Defaults to the Oracle standard `1521`."
  type        = number
  default     = 1521
}

variable "container_port" {
  description = "Pod port the TNS listener binds to inside the container. Defaults to `1521`; only change when overriding the image entrypoint."
  type        = number
  default     = 1521
}

variable "oracle_pwd" {
  type        = string
  default     = "topSecretpa33word"
  description = "SYS/SYSTEM/PDBADMIN password injected via the `ORACLE_PWD` env var. Demo default is intentionally low-effort — rotate when exposing the DB outside the cluster."
  sensitive   = true
}

variable "oracle_characterset" {
  type        = string
  default     = "AL32UTF8"
  description = "Database character set passed via the `ORACLE_CHARACTERSET` env var at first boot. AL32UTF8 is the Oracle-recommended UTF-8 default; only change for legacy compatibility."
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
