#!/usr/bin/env bash
set -euo pipefail

SRC_ISO="${1:?usage: $0 <official-pve-iso>}"
OUT_DIR="/var/lib/vz/template/iso"
ROOTPW="sD5IuSZiEhHBm07E0Hc3SnBbav2JuWUjnHlIRgLj"

NODES=(
	"pve-node-1 10.10.10.11/24 bc241110:0011"
	"pve-node-2 10.10.10.12/24 bc241110:0012"
	"pve-node-3 10.10.10.13/24 bc241110:0013"
      )

for entry in "${NODES[@]}"; do
      read -r name cidr mac <<<"$entry"
      mac="${mac//:/}"
      answer="/tmp/answer-${name}.toml"
      sed -e "s|@HOSTNAME@|${name}|" \
	     -e "s|@CIDR@|${cidr}|" \
	     -e "s|@MACFILTER@|${mac}|" \
	     -e "s|@ROOTPW@|${ROOTPW}|" \
	     /root/install-pve-nodes/answer.toml.tpl > "$answer"

      proxmox-auto-install-assistant validate-answer "$answer"
      proxmox-auto-install-assistant prepare-iso "$SRC_ISO" --fetch-from iso --answer-file "$answer" --output "${OUT_DIR}/proxmox-ve-auto-${name}.iso"

      rm -f "$answer"
      echo "ISO construite : ${OUT_DIR}/proxmox-ve-auto-${name}.iso"
done

echo "Tache realisee. MDP root pour les 3 noeuds : ${ROOTPW}"
