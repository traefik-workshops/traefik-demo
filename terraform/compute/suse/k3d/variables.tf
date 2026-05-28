variable "cluster_name" {
  type        = string
  description = "k3d cluster name."
}

variable "control_plane_nodes" {
  type = object({
    count = number
  })
  default     = { count : 1 }
  description = "Cluster Control Plane node config."
}

variable "worker_nodes" {
  type = list(object({
    label = string
    taint = string
    count = number
  }))
  default     = []
  description = "Worker node pools to create. Each entry sizes one pool with `count` agents and applies the given Kubernetes `label` and `taint`. Default `[]` runs control-plane-only — fine for small demos."
}

variable "ports" {
  description = "Host→cluster port mappings exposed by the k3d load balancer. Default opens 80/443 (HTTP/HTTPS) and 8080 (Traefik dashboard) on the host. Add entries for any extra ingress ports the demo needs."
  type = list(object({
    from = number
    to   = number
  }))
  default = [
    { from : 80, to : 80 },
    { from : 443, to : 443 },
    { from : 8080, to : 8080 },
  ]
}

variable "volumes" {
  type        = list(string)
  default     = []
  description = "Volume mounts in 'host_path:container_path' format, applied to all nodes."
}

variable "host_aliases" {
  type = list(object({
    ip        = string
    hostnames = list(string)
  }))
  default     = []
  description = "Entries injected into /etc/hosts on nodes and CoreDNS."
}

variable "registries_use" {
  type        = list(string)
  default     = []
  description = "Names of existing k3d-managed registries to attach to this cluster's network."
}

variable "registries_config" {
  type        = string
  default     = ""
  description = "Contents of /etc/rancher/k3s/registries.yaml rendered into the cluster (mirrors/auth)."
}
