output "vm_uuid" {
  description = "Vm uuid."
  value       = nutanix_virtual_machine.vm.id
}

output "vm_name" {
  description = "Vm name."
  value       = nutanix_virtual_machine.vm.name
}

output "ip_address" {
  description = "Ip address."
  value       = length(nutanix_virtual_machine.vm.nic_list_status) > 0 ? nutanix_virtual_machine.vm.nic_list_status[0].ip_endpoint_list[0].ip : ""
}
