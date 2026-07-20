variable "pm_endpoint" {
  description = "API du cluster (on prend le noeud principal comme réference)"
  type        = string
  default     = "https://10.10.10.11:8006/"
}

variable "pm_api_token" {
  description = "Token API cluster"
  type        = string
  sensitive   = true
}

variable "template_node" {
  description = "Noeud qui héberge le template"
  type        = string
  default     = "pve-node-1"
}

variable "prod_bridge" {
  description = "Bridge production dans les noeuds imbriqués (vmbr1 relié au vmbr3 de l'hôte)"
  type        = string
  default     = "vmbr1"
}

variable "ci_user" {
  description = "Utilisateur créé par cloud-init sur les VMs"
  type        = string
  default     = "benco"
}

variable "ci_ssh_key" {
  description = "Clé publique SSH injectée, celle de benco@mgmt01"
  type        = string
}

variable "prod_dns" {
  description = "Résolveur des VMs prod (10.10.30.1 = dnsmasq, bascule vers dns01 plus tard)"
  type        = string
  default     = "10.10.30.1"
}

variable "prod_domain" {
  type    = string
  default = "poc.bencopharma.lab"
}

variable "prod_vms" {
  type = map(object({
    vmid   = number
    ip     = string
    node   = string
    cores  = number
    memory = number
    data_disk   = number
  }))
  default = {
    dns01    = { vmid = 210, ip = "10.10.30.10/24", node = "pve-node-1", cores = 2, memory = 2048, data_disk = 0 }
    krb01    = { vmid = 212, ip = "10.10.30.12/24", node = "pve-node-2", cores = 2, memory = 2048, data_disk = 0 }
    docker01 = { vmid = 213, ip = "10.10.30.13/24", node = "pve-node-3", cores = 4, memory = 6144, data_disk = 30 }
  }
}

