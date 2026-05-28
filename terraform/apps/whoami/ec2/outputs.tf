output "instances" {
  description = "Map of all echo server instances with their details"
  value       = module.echo_instances.instances
}
