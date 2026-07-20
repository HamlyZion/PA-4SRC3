[global]
keyboard = "fr"
country = "fr"
fqdn = "@HOSTNAME@.poc.bencopharma.lab"
mailto = "root@poc.bencopharma.lab"
timezone = "Europe/Paris"
root-password = "@ROOTPW@"
reboot-on-error = false

[network]
source = "from-answer"
cidr = "@CIDR@"
gateway = "10.10.10.1"
dns = "10.10.10.1"
# Select the management NIC by its fixed MAC (set by Terraform)
filter.ID_NET_NAME_MAC = "*@MACFILTER@"

[disk-setup]
filesystem = "ext4"
disk-list = ["sda"]
lvm.maxvz = 40
