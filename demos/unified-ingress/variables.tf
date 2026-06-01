# --- AWS / EKS hub ------------------------------------------------------------
variable "cluster_name" {
  type        = string
  description = "Name for the EKS hub cluster (and its VPC)."
  default     = "unified-ingress"
}

variable "region" {
  type        = string
  description = "AWS region for the EKS hub and the EC2/ECS spokes."
  default     = "us-east-1"
}

variable "cluster_node_type" {
  type        = string
  description = "EKS hub node instance type. Use a non-burstable m-series SKU — the hub runs sustained (Keycloak, Langfuse+ClickHouse, Grafana stack, OTel, SPIRE, APIM). Default m5.2xlarge = 8 vCPU / 32 GB (~7.7 vCPU allocatable/node)."
  default     = "m5.2xlarge"
}

variable "cluster_node_count" {
  type        = number
  description = "EKS hub node count. The hub stack requests ~6.5 vCPU + ~0.7 vCPU kube-system; 2x m5.2xlarge (~15.4 vCPU allocatable) holds that ~48% requested, so CPU peaks ~60% with headroom for boot spikes (Keycloak realm import, ClickHouse init, Prometheus)."
  default     = 2
}

# --- Azure / AKS spoke --------------------------------------------------------
variable "resource_group_name" {
  type        = string
  description = "Azure resource group to create for the AKS spoke."
  default     = "unified-ingress-rg"
}

variable "azure_region" {
  type        = string
  description = "Azure region for the resource group + AKS spoke."
  default     = "eastus"
}

variable "aks_version" {
  type        = string
  description = "AKS Kubernetes version."
  default     = "1.34"
}

variable "aks_node_type" {
  type        = string
  description = "AKS spoke node VM size. Non-burstable D-series — the spoke runs the AI gateway (Presidio) + SPIRE. Default Standard_D4s_v5 = 4 vCPU / 16 GB."
  default     = "Standard_D4s_v5"
}

variable "aks_node_count" {
  type        = number
  description = "AKS spoke node count. 2x D4s_v5 (~7.7 vCPU allocatable) holds the child Traefik + AI gateway + Presidio + SPIRE at ~35% requested."
  default     = 2
}

# --- DNS + TLS ----------------------------------------------------------------
variable "domain" {
  type        = string
  description = "Base demo domain. Everything is exposed under it: whoami.<domain>, dashboard.<domain>, legacy.<domain> (and, in later phases, portal./keycloak./grafana./langfuse./ai./mcp.<domain>). Must live in the Cloudflare zone the dns-traefiker controller's token can edit — dns-traefiker registers the records and Traefik's cf resolver issues the certs (both read the Cloudflare token from the dns-traefiker domain-secret, so the demo takes no Cloudflare input)."
}

# --- Traefik Hub --------------------------------------------------------------
variable "traefik_hub_token" {
  type        = string
  description = "Traefik Hub license token (offline JWT)."
  sensitive   = true
}

# --- AI gateway (on the AKS spoke) --------------------------------------------
variable "openai_api_key" {
  type        = string
  description = "Upstream OpenAI-compatible API key the AI gateway's chat-completion middleware injects. Guard/limit scenarios block at the gateway, so a placeholder is fine for those; the happy path needs a real key (or a mock backend)."
  sensitive   = true
  default     = "REPLACE_ME"
}

variable "backend_external_name" {
  type        = string
  description = "OpenAI-compatible upstream host the AI gateway forwards to (ExternalName)."
  default     = "api.openai.com"
}

variable "token_limit" {
  type        = number
  description = "Per-hour total token budget enforced by the AI gateway's Redis-backed rate-limit."
  default     = 100000
}

# --- Spoke toggles (phased deploys) -------------------------------------------
variable "enable_vm_spokes" {
  type        = bool
  description = "Deploy the EC2 (VM) + ECS (Fargate) Hub uplink spokes. Set false to stand up just the EKS hub + AKS spoke first — the EC2/ECS uplinks are the least-verified part, so bring them up in a second round."
  default     = true
}

# --- API Management / Keycloak ------------------------------------------------
variable "keycloak_client_secret" {
  type        = string
  description = "OIDC client secret for the Keycloak `traefik` client. MUST match the helm/keycloak chart's realm.clientSecret (the portal's oidc-credentials Secret uses this value). Default is the chart default."
  sensitive   = true
  default     = "NoTgoLZpbrr5QvbNDIRIvmZOhe9wI0r0"
}
