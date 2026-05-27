output "vm_uuid" {
  value = nutanix_virtual_machine.vm.id
}

output "vm_name" {
  value = nutanix_virtual_machine.vm.name
}

output "ip_address" {
  value = length(nutanix_virtual_machine.vm.nic_list_status) > 0 ? nutanix_virtual_machine.vm.nic_list_status[0].ip_endpoint_list[0].ip : ""
}
