# Phase 4 — ECS spoke (Traefik Hub on Fargate, joined as a multicluster uplink
# child). Same caveats as the EC2 spoke (spokes-ec2.tf): the Fargate-Hub uplink
# advertising + SPIFFE-on-ECS (a SPIRE agent sidecar with aws_iid) are best-effort
# and verified on a live apply. The hub verifies the ECS uplink with
# insecureSkipVerify (main.tf) until the SPIRE-on-ECS extension lands. Fallback:
# front the ECS whoami from the hub via an ExternalName service.

module "ecs_whoami" {
  source = "../../terraform/apps/whoami/ecs"
  count  = var.enable_vm_spokes ? 1 : 0

  name = "${var.cluster_name}-ecs-whoami"
}

module "ecs_traefik" {
  source = "../../terraform/traefik/ecs"
  count  = var.enable_vm_spokes ? 1 : 0

  traefik_hub_token   = var.traefik_hub_token
  enable_api_gateway  = true
  enable_offline_mode = true

  multicluster_provider = { enabled = true }
  custom_ports = {
    ecs-uplink = { port = 9443 }
  }
  custom_arguments = [
    "--hub.uplinkEntryPoints.ecs.address=:9443",
    "--hub.uplinkEntryPoints.ecs.http.tls=true",
  ]

  enable_otlp_metrics = true
  enable_otlp_traces  = true
  otlp_service_name   = "traefik-ecs"
  otlp_address        = "https://otel.${var.domain}"
}

locals {
  # The ECS Hub's public load balancer address — the hub dials https://<lb>:9443.
  # The exact services-output shape is verified live; placeholder keeps validate
  # happy and is set by hand at apply (or swapped for the ExternalName fallback).
  ecs_uplink_address = var.enable_vm_spokes ? "https://${try(one(values(module.ecs_traefik[0].services)).dns_name, "PENDING")}:9443" : ""
}
