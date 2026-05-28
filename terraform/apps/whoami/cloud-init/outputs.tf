output "rendered" {
  description = "Rendered."
  value = templatefile("${path.module}/cloud-init.tpl", {
    whoami_version = var.whoami_version
    arch           = var.arch
    port           = var.port
  })
}
