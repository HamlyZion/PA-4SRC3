# La VM 9000 boote l'ISO kickstart, s'installe seule puis s'éteint.
# On la fige ensuite en template : qm set 9000 --ide3 none && qm template 9000     (sur son noeud)

resource "proxmox_virtual_environment_vm" "rocky10_template" {
  name      = "rocky10-hardened-template"
  vm_id     = 9000
  node_name = var.template_node
  tags      = ["template", "rocky10", "hardened"]

  machine       = "q35"
  bios          = "seabios"
  scsi_hardware = "virtio-scsi-single"

  cpu {
    cores = 2
    type  = "host"
  }

  memory {
    dedicated = 2048
  }

  disk {
    datastore_id = "vm-pool"
    interface    = "scsi0"
    size         = 24
    discard      = "on"
    iothread     = true
  }

  cdrom {
    file_id = "cephfs:iso/rocky10-hardened-ks.iso"
  }

  boot_order = ["scsi0", "ide3"]

  network_device {
    bridge = var.prod_bridge
  }

  serial_device {} # le kickstart route la console sur ttyS0 : suivi possible en série

  operating_system {
    type = "l26"
  }

  lifecycle {
    ignore_changes = [template, cdrom, started]
  }
}

