locals {
  ha_vms = merge(
    { for k, v in var.prod_vms : k => v.vmid },
    { dc01 = 211 }
  )
}

resource "proxmox_haresource" "prod" {
  for_each    = local.ha_vms
  resource_id = "vm:${each.value}"
  state       = "started"
  comment     = "PoC production - ${each.key} (managed by Terraform)"

  max_restart  = 1
  max_relocate = 1

  depends_on = [
    proxmox_virtual_environment_vm.prod,
    proxmox_virtual_environment_vm.dc01,
  ]
}
