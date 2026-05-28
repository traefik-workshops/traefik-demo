data "external" "registry_auth" {
  program = ["bash", "${path.module}/scripts/manage_registry_auth.sh"]

  query = {
    action         = "create"
    name           = "ngc-nvcr-registry-auth"
    username       = var.ngc_username
    password       = var.ngc_token
    runpod_api_key = var.runpod_api_key
  }
}

# Clean up registry auth when destroyed
resource "null_resource" "registry_auth_cleanup" {
  triggers = {
    name           = "ngc-nvcr-registry-auth"
    runpod_api_key = var.runpod_api_key
  }

  provisioner "local-exec" {
    when    = destroy
    command = <<-EOT
      bash ${path.module}/scripts/manage_registry_auth.sh << 'EOF'
      {
        "action": "delete",
        "name": "${self.triggers.name}",
        "runpod_api_key": "${self.triggers.runpod_api_key}",
        "username": "",
        "password": ""
      }
      EOF
    EOT
  }

  depends_on = [data.external.registry_auth]
}
