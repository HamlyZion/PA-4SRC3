terraform {
  required_version = ">= 1.6"
  required_providers {
    proxmox = {
      source  = "bpg/proxmox"
      version = "~> 0.84"
    }
  }
}

provider "proxmox" {
  endpoint  = var.pm_endpoint   
  api_token = var.pm_api_token  
  insecure  = true              
}
