variable "cluster_name" {
  type        = string
  description = "k3d cluster name."
  default     = "hub-from-source"
}

variable "domain" {
  type        = string
  description = "Domain the demo routes are exposed on. With k3d this resolves to localhost, so any *.localhost works."
  default     = "hub-from-source.localhost"
}

variable "traefik_hub_token" {
  type        = string
  description = "Traefik Hub license token (offline JWT). Hub is licensed software — even a from-source build needs a valid token. Get one at https://hub.traefik.io."
  sensitive   = true
}

variable "local_traefik_hub" {
  type        = bool
  description = "When true, run the Traefik Hub image built from source (localhost:5001/traefik/traefik-hub:dev) instead of the released image. Run `make build-hub` first. Defaults false so `make up` works without a Hub source checkout."
  default     = false
}

variable "registry_name" {
  type        = string
  description = "Name of the k3d-managed registry that holds the from-source image. `make registry` creates it. Only used when local_traefik_hub = true."
  default     = "k3d-hub-from-source-registry"
}
