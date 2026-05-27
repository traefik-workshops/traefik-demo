output "pods" {
  description = "Map of created pods with their details"

  value = { for k, v in module.nims.pods : k => {
    id   = v.id
    host = v.host
  } }

  depends_on = [module.nims]
}
