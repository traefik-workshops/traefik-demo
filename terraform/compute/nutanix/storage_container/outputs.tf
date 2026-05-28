output "id" {
  description = "UUID of the storage container"
  value       = nutanix_storage_containers_v2.container.id
}

output "name" {
  description = "Name of the storage container"
  value       = nutanix_storage_containers_v2.container.name
}

output "ext_id" {
  description = "External ID of the storage container"
  value       = nutanix_storage_containers_v2.container.ext_id
}
