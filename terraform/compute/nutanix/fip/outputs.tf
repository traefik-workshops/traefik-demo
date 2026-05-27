output "public_ip" {
  description = "The allocated Floating IP address"
  value       = try(nutanix_floating_ip_v2.vm_fip[0].floating_ip[0].ipv4[0].value, nutanix_floating_ip_v2.vpc_fip[0].floating_ip[0].ipv4[0].value, "")
}

output "id" {
  description = "The ID of the Floating IP"
  value       = try(nutanix_floating_ip_v2.vm_fip[0].id, nutanix_floating_ip_v2.vpc_fip[0].id, "")
}
