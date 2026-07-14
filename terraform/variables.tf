variable "pm_endpoint" {
  description = "Proxmox-host API endpoint"
  type        = string
}

variable "pm_api_token" {
  description = "Token pour l'API du compte terraform"
  type        = string
  sensitive   = true
}

variable "host_node" {
  description = "Nom de la machine hôte"
  type        = string
  default     = "proxmox-host"
}

variable "datastore" {
  description = "Datastore Proxmox-host"
  type        = string
  default     = "local"
}

variable "pve_nodes" {
  type = map(object({
    vmid     = number
    mac_mgmt = string
  }))
  default = {
    pve-node-1 = { vmid = 111, mac_mgmt = "BC:24:11:10:00:11" }
    pve-node-2 = { vmid = 112, mac_mgmt = "BC:24:11:10:00:12" }
    pve-node-3 = { vmid = 113, mac_mgmt = "BC:24:11:10:00:13" }
  }
}
