# Validate that required tools are installed and configured
data "external" "validate_requirements" {
  program = ["bash", "${path.module}/scripts/validate_requirements.sh"]

  query = {}
}

data "external" "pods" {
  for_each = var.pods

  program = ["bash", "${path.module}/scripts/manage_pod.sh"]

  query = {
    action               = "create"
    name                 = each.value.name
    image                = each.value.image
    tag                  = each.value.tag
    command              = each.value.command
    runpod_api_key       = var.runpod_api_key
    ngc_token            = var.ngc_token
    hugging_face_api_key = var.hugging_face_api_key
    pod_type             = each.value.pod_type
    registry_auth_id     = var.registry_auth_id
  }

  depends_on = [data.external.validate_requirements]
}

# Clean up pods when destroyed
resource "null_resource" "pods_cleanup" {
  for_each = var.pods

  triggers = {
    name           = each.value.name
    runpod_api_key = var.runpod_api_key
  }

  provisioner "local-exec" {
    when    = destroy
    command = <<-EOT
      runpodctl remove pods ${self.triggers.name} || true
    EOT
  }

  depends_on = [data.external.pods]
}
