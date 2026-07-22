#!/usr/bin/env bash
set -euo pipefail

OUT_ISO="dc01-extras.iso"
VIRTIO_URL="https://fedorapeople.org/groups/virt/virtio-win/direct-downloads/latest-virtio/virtio-win.iso"
NODE="${PVE_NODE:-10.10.10.11}"
BUILD="$(pwd)/build-extras"

rm -rf "$BUILD" && mkdir -p "$BUILD/virtio"

#Drivers virtio 2k22 + guest tools
[ -f virtio-win.iso ] || curl -Lo virtio-win.iso "$VIRTIO_URL"
MNT=$(mktemp -d)
sudo mount -o loop,ro virtio-win.iso "$MNT"
for drv in vioscsi viostor NetKVM Balloon; do
  mkdir -p "$BUILD/virtio/${drv}/2k22/amd64"
  cp -r "$MNT/${drv}/2k22/amd64/." "$BUILD/virtio/${drv}/2k22/amd64/"
done
cp "$MNT/virtio-win-gt-x64.msi" "$BUILD/virtio/"
sudo umount "$MNT" && rmdir "$MNT"

# Fichiers
sed -e "s/CHANGE-ME-Adm1n!/${WIN_ADMIN_PW}/g" autounattend.xml > "$BUILD/autounattend.xml"
cp postinstall.ps1 "$BUILD/postinstall.ps1"

genisoimage -J -R -V "DC01_EXTRAS" -o "$OUT_ISO" "$BUILD"

scp "$OUT_ISO" "root@${NODE}:/mnt/pve/cephfs/template/iso/"
echo "OK : cephfs:iso/${OUT_ISO} ($(du -h "$OUT_ISO" | cut -f1))"
