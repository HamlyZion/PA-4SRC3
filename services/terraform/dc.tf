resource "proxmox_virtual_environment_vm" "dc01" {
  name      		= "dc01"
  vm_id     		= 211
  node_name 		= "pve-node-2"
  tags      		= ["poc", "production", "windows"]
  on_boot   		= true
  keyboard_layout	= "fr"
  machine       	= "q35"
  bios          	= "seabios"
  scsi_hardware 	= "virtio-scsi-single"
  started 		= false

  cpu {
    cores = 4
    type  = "host"
  }

  memory {
    dedicated = 8192
  }

  disk {
    datastore_id = "vm-pool"
    interface    = "scsi0"
    size         = 60
    discard      = "on"
    iothread     = true
  }

  cdrom {
    file_id = "cephfs:iso/Win-2022.iso"
  }

  boot_order = ["scsi0", "ide3"]

  network_device {
    bridge = "vmbr1"
  }

  operating_system {
    type = "win11"
  }

  agent {
    enabled = true
    timeout = "60m"
  }

  lifecycle {
    ignore_changes = [cdrom]
  }
}

