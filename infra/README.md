# PoC bencopharma — Infrastructure as Code

Déploiement automatisé d'un cluster Proxmox VE avec stockage Ceph
hyperconvergé sur un serveur bare-metal, via Terraform et Ansible.

## Architecture

- Hôte : Proxmox VE 9.2 (bare-metal OVH, Ryzen 9950X3D, 64 Go, 2×960 Go NVMe RAID1)
- Cluster imbriqué : 3 nœuds PVE (VMs) installés sans intervention via les answer files de l'installeur automatisé Proxmox
- Stockage : Ceph hyperconvergé (3 MON/MGR/OSD/MDS) — pool RBD pour les disques VM, CephFS pour backups et ISO
- Réseaux : management (10.10.10.0/24), stockage/Ceph (10.10.20.0/24,jumbo frames), production (10.10.30.0/24) — NAT via l'hôte
- Contrôleur : VM mgmt01 (Rocky 10) portant Terraform et Ansible

## Strucure 

autoinstall/    Génération des ISO auto-install PVE (answer.toml + script) -> a executer sur le /root de proxmox host
terraform/      Déploiement des noeuds/VMs (provider bpg/proxmox, token API dédié)
ansible/        Configuration : base, réseau, cluster, Ceph

## Déploiement

```
export TF_VAR_pm_api_token='terraform@pve!terraform=<secret>'
cd terraform && terraform init && terraform apply

cd ../ansible
ansible-playbook -i inventory.ini playbooks/base-install.yml --ask-pass
ansible-playbook -i inventory.ini playbooks/network_conf.yml
ansible-playbook -i inventory.ini playbooks/cluster_conf.yml
ansible-playbook -i inventory.ini playbooks/ceph_conf.yml
```

Validation : pvecm status (3 nœuds, quorum) et ceph -s (HEALTH_OK).

## Notes

- Les playbooks sont idempotents et peuvent être rejoués à tout instant
- Lab de démonstration : un seul serveur physique (SPOF assumé), certificats auto-signés, performances non représentatives (virtualisation imbriquée).
