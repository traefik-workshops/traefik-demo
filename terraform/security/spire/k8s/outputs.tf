output "trust_domain" {
  value       = var.trust_domain
  description = "SPIFFE trust domain rooting every SVID this server issues."
}

output "cluster_name" {
  value       = var.cluster_name
  description = "Logical cluster name used for node attestation and SVID paths."
}

output "namespace" {
  value       = var.namespace
  description = "Namespace SPIRE is installed into."
}

output "workload_api_socket_path" {
  value       = "/spiffe-workload-api/spire-agent.sock"
  description = "In-pod path where the spiffe-csi-driver (csi.spiffe.io) mounts the Workload API socket. Mount that CSI volume here in a consumer pod and point Traefik at --spiffe.workloadAPIAddress=unix://<this>."
}

output "federation_bundle_endpoint" {
  # Conventional in-cluster federation Service for the hardened chart; expose it
  # externally (LoadBalancer / IngressRoute) for cross-cloud peers and reference
  # that external URL from each peer's ClusterFederatedTrustDomain. Confirmed
  # live in the Phase 2 EKS<->AKS spike.
  value       = var.enable_federation ? "https://spire-server-federation.${var.namespace}:8443" : ""
  description = "In-cluster federation bundle endpoint peers fetch this cluster's trust bundle from (empty unless enable_federation). Expose externally for cross-cloud federation."
}
