output "pods" {
  description = "Map of created pods with their details"

  value = { for k, v in module.llms.pods : k => {
    id   = v.id
    host = v.host
  } }

  depends_on = [module.llms]
}
