output "pods" {
  description = "Map of created pods with their details"
  value       = { for k, v in data.external.pods : k => v.result }
}
