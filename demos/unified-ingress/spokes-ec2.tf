# Phase 4 — EC2 spoke (Traefik Hub on a VM, joined as a multicluster uplink child).
#
# HIGHEST-RISK / least-verified phase: no reference composition runs Hub on a VM
# as a multicluster child. The module surface supports it (multicluster_provider +
# custom_arguments + custom_ports + create_eip for a stable public address), so the
# connectivity is wired here — but two things are BEST-EFFORT and verified on a live
# apply (see PLAN.md):
#   1. Advertising the EC2 whoami over the VM uplink (on k8s this is the Uplink CRD;
#      on a VM it's the file provider's http.uplinks — wired by hand at apply).
#   2. SPIFFE on this uplink needs a SPIRE agent on the VM (aws_iid attestor). Until
#      then the hub verifies the EC2 uplink with insecureSkipVerify (main.tf), and
#      SPIFFE-on-VM is the documented extension.
# Fallback if the Hub-on-VM uplink proves unworkable: front the EC2 whoami from the
# hub via an ExternalName/Endpoints service (coexistence without the uplink).

module "ec2_whoami" {
  source = "../../terraform/apps/whoami/ec2"
  count  = var.enable_vm_spokes ? 1 : 0
  # Defaults: one whoami instance in its own VPC. The EC2 Hub routes to it.
}

module "ec2_traefik" {
  source = "../../terraform/traefik/ec2"
  count  = var.enable_vm_spokes ? 1 : 0

  traefik_hub_token   = var.traefik_hub_token
  enable_api_gateway  = true
  enable_offline_mode = true
  create_eip          = true # stable public address the hub dials

  # Multicluster child + a Hub uplink entrypoint on :9443 (the EKS hub dials it).
  multicluster_provider = { enabled = true }
  custom_ports = {
    ec2-uplink = { port = 9443 }
  }
  custom_arguments = [
    "--hub.uplinkEntryPoints.ec2.address=:9443",
    "--hub.uplinkEntryPoints.ec2.http.tls=true",
  ]

  enable_otlp_metrics = true
  enable_otlp_traces  = true
  otlp_service_name   = "traefik-ec2"
  otlp_address        = "https://otel.${var.domain}"
}

locals {
  # The EC2 Hub's Elastic IP — the hub dials https://<eip>:9443. Empty when VM
  # spokes are off; `try` keeps validate happy before the IP exists.
  ec2_uplink_address = var.enable_vm_spokes ? "https://${try(values(module.ec2_traefik[0].public_ips)[0], "PENDING")}:9443" : ""
}
