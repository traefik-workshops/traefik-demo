locals {
  parsed = yamldecode(var.kubeconfig)

  # Resolve the active context: explicit current-context if set, else first listed.
  ctx_name = try(local.parsed["current-context"], local.parsed.contexts[0].name)
  ctx      = [for c in local.parsed.contexts : c.context if c.name == local.ctx_name][0]

  cluster_obj = [for c in local.parsed.clusters : c.cluster if c.name == local.ctx.cluster][0]
  user_obj    = [for u in local.parsed.users : u.user if u.name == local.ctx.user][0]

  host = local.cluster_obj.server

  # CA can arrive as base64'd `certificate-authority-data` or as a path under
  # `certificate-authority`. Demos typically use the data form; the path form
  # only works on the machine that produced the kubeconfig, so we leave it
  # empty here and let the caller pass it explicitly if needed.
  cluster_ca_certificate = try(base64decode(local.cluster_obj["certificate-authority-data"]), "")

  # Token-based auth is the easy case. Exec-based auth (EKS aws-iam-authenticator,
  # GKE gke-gcloud-auth-plugin, ...) does not expose a static token here — the
  # token is empty, and downstream providers must be wired via `config_path =
  # var.kubeconfig_file` (write kubeconfig to a temp file) instead of host+token.
  token = try(local.user_obj.token, "")
}

output "host" {
  description = "Imported cluster API server URL (parsed from kubeconfig)."
  value       = local.host
  sensitive   = true
}

output "cluster_ca_certificate" {
  description = "Imported cluster CA certificate (PEM, decoded from `certificate-authority-data`). Empty when the kubeconfig uses a CA file path or exec auth — pass the CA explicitly downstream in that case."
  value       = local.cluster_ca_certificate
  sensitive   = true
}

output "token" {
  description = "Imported cluster auth token (parsed from the kubeconfig's user). Empty when the kubeconfig uses exec auth — wire downstream providers via `config_path` to the kubeconfig file instead."
  value       = local.token
  sensitive   = true
}

output "kubeconfig" {
  description = "Imported cluster kubeconfig, passed through unchanged. Use this when downstream providers can take `config_path` or a raw kubeconfig string."
  value       = var.kubeconfig
  sensitive   = true
}

output "cluster_id" {
  description = "Imported cluster identifier. Mirrors `cluster_name` since there is no provider-side cluster ID for an imported cluster."
  value       = var.cluster_name
}

output "cluster_name" {
  description = "Imported cluster name (echo of the input, for downstream tagging)."
  value       = var.cluster_name
}
