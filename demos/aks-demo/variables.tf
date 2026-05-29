# --- Azure -------------------------------------------------------------------
variable "resource_group_name" {
  type        = string
  description = "Azure resource group to create and place the AKS cluster in."
  default     = "aks-demo-rg"
}

variable "cluster_name" {
  type        = string
  description = "AKS cluster name."
  default     = "aks-demo"
}

variable "region" {
  type        = string
  description = "Azure region for the resource group + AKS cluster."
  default     = "westus"
}

variable "aks_version" {
  type        = string
  description = "AKS Kubernetes version."
  default     = "1.34"
}

variable "cluster_node_type" {
  type        = string
  description = "AKS node VM size. Use a NON-burstable (D-series) SKU — the stack runs sustained and burstable B-series throttles below baseline. Default Standard_D4s_v5 = 4 vCPU / 16 GB (~3.86 vCPU allocatable per node after the kubelet reservation)."
  default     = "Standard_D4s_v5"
}

variable "cluster_node_count" {
  type        = number
  description = "AKS node count. The stack requests ~5 vCPU + ~0.7 vCPU kube-system; 3x D4s_v5 (~11.6 vCPU allocatable) holds that at ~50% requested, so CPU peaks land ~60% with headroom for boot spikes (Keycloak realm import, Langfuse migrations, ClickHouse init)."
  default     = 3
}

# --- DNS + TLS ----------------------------------------------------------------
variable "domain" {
  type        = string
  description = "Base demo domain. Everything is exposed under it: portal.<domain>, keycloak.<domain>, whoami.<domain>, grafana.<domain>, langfuse.<domain>, dashboard.<domain>. Must live in the Cloudflare zone the dns-traefiker controller's token can edit — dns-traefiker registers the records and Traefik's `cf` resolver issues the certs (both read the Cloudflare token from the dns-traefiker `domain-secret`, so the demo takes no Cloudflare input)."
}

# --- Traefik Hub --------------------------------------------------------------
variable "traefik_hub_token" {
  type        = string
  description = "Traefik Hub license token (offline JWT)."
  sensitive   = true
}

# --- Keycloak -----------------------------------------------------------------
variable "keycloak_client_secret" {
  type        = string
  description = "OIDC client secret for the Keycloak `traefik` client. MUST match the helm/keycloak chart's realm.clientSecret (the portal's oidc-credentials Secret uses this value). Default is the chart default."
  sensitive   = true
  default     = "NoTgoLZpbrr5QvbNDIRIvmZOhe9wI0r0"
}
