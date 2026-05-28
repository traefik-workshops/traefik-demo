locals {
  matching_rule = "ALL {instance.compartment.id = '${var.compartment_id}'}"
}

resource "oci_identity_dynamic_group" "traefik_instance_principals_dynamic_group" {
  compartment_id = var.compartment_id
  description    = "Dynamic group for instance principals demo with Traefik"
  matching_rule  = local.matching_rule
  name           = "instance-principals-traefik-demo"
}

resource "oci_identity_policy" "traefik_instance_principals_policy" {
  compartment_id = var.compartment_id
  description    = "Policy for instance principals demo with Traefik"
  name           = "instance-principals-traefik-demo"
  statements     = ["Allow dynamic-group instance-principals-traefik-demo to manage all-resources in tenancy"]
}
