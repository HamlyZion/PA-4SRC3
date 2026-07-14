resource "proxmox_virtual_environment_vm" "pve" {
  for_each  = var.pve_nodes
  name      = each.key
  vm_id     = each.value.vmid
  node_name = var.host_node
  tags      = ["poc", "hypervisor"]
  on_boot   = true

  machine       = "q35"
  bios          = "seabios"
  scsi_hardware = "virtio-scsi-single"

  keyboard_layout = "fr"

  cpu {
    cores = 8
    type  = "host" 
  }

  memory {
    dedicated = 16384 
  }

# OS
  disk {
    datastore_id = var.datastore
    interface    = "scsi0"
    size         = 80
    file_format  = "qcow2"
    discard      = "on"
    iothread     = true
  }

# Ceph
  disk {
    datastore_id = var.datastore
    interface    = "scsi1"
    size         = 150
    file_format  = "raw"
    discard      = "on"
    iothread     = true
  }

  cdrom {
    file_id = "${var.datastore}:iso/proxmox-ve-auto-${each.key}.iso"
  }

# On tente le boot sur le disque OS et si ca marche pas il boot sur l'iso, unqiuement pour l'install
  boot_order = ["scsi0", "ide3"]

# net0 mgmt, on force la mac de cette interface (créée dans la creation de l'ISO) pour être sûr que chaque noeud prend la bonne interface pour la bonne ip
  network_device {
    bridge      = "vmbr1"
    mac_address = each.value.mac_mgmt
  }

# net1 ceph
  network_device {
    bridge = "vmbr2"
    mtu    = 1 
  }

# net2 prod
  network_device {
    bridge = "vmbr3"
  }

  operating_system {
    type = "l26"
  }

# Ejecter l'ISO sans le diff à la fin de l'install
  lifecycle {
    ignore_changes = [cdrom] 
  }
}

# k c'est le nom des noeuds et v la data dedans (vmid et mac address)
# On utilise le nom du node pour lui donner son ip en prenant le 9eme caractere
output "pve_nodes" {
  value = { for k, v in var.pve_nodes : k => "10.10.10.${10 + tonumber(substr(k, 9, 1))}" }
}
