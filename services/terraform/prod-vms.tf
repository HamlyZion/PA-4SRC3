resource "proxmox_virtual_environment_vm" "prod" {
  for_each  = var.prod_vms
  name      = each.key
  vm_id     = each.value.vmid
  node_name = each.value.node
  tags      = ["poc", "production"]
  on_boot   = true

  clone {
    vm_id        = proxmox_virtual_environment_vm.rocky10_template.vm_id
    node_name    = var.template_node
    full         = true
    datastore_id = "vm-pool"
  }

  machine       = "q35"
  scsi_hardware = "virtio-scsi-single"

  cpu {
    cores = each.value.cores
    type  = "host"
  }

  memory {
    dedicated = each.value.memory
  }

  # Disque data optionnel (data_disk > 0)
  dynamic "disk" {
    for_each = each.value.data_disk > 0 ? [1] : []
    content {
      datastore_id = "vm-pool"
      interface    = "scsi1"
      size         = each.value.data_disk
      file_format  = "raw"
      discard      = "on"
      iothread     = true
    }
  }

  network_device {
    bridge = var.prod_bridge
  }

  serial_device {}

  agent {
    enabled = false
  }

  initialization {
    datastore_id = "vm-pool"

    ip_config {
      ipv4 {
        address = each.value.ip
        gateway = "10.10.30.1"
      }
    }

    dns {
      servers = [var.prod_dns]
      domain  = var.prod_domain
    }

    user_account {
      username = var.ci_user
      keys     = [var.ci_ssh_key]
    }
  }

  lifecycle {
    ignore_changes = [initialization[0].user_account]
  }
}

output "prod_vms" {
  value = { for k, v in var.prod_vms : k => "${split("/", v.ip)[0]} on ${v.node}" }
}

