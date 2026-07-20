#!/usr/bin/env bash
set -euo pipefail

SRC_ISO="${1:?usage: $0 <Rocky-10-minimal.iso>}"
OUT_ISO="rocky10-hardened-ks.iso"
NODE="${PVE_NODE:-10.10.10.11}"

if command -v ksvalidator >/dev/null; then
  ksvalidator ks.cfg || { echo "ks.cfg invalide"; exit 1; }
fi

# Injecte le ks.cfg et l'ajoute à la ligne de commande kernel (inst.ks)
sudo mkksiso --ks ks.cfg "${SRC_ISO}" "${OUT_ISO}"

echo "Upload vers ${NODE}:/mnt/pve/cephfs/template/iso/ ..."
scp "${OUT_ISO}" "root@${NODE}:/mnt/pve/cephfs/template/iso/"

echo "OK — l'ISO est visible du cluster entier (cephfs:iso/${OUT_ISO})."
