#!/usr/bin/env bash
set -euo pipefail

PKI="${HOME}/pki"
DAYS=1825
umask 077

[ -f "${PKI}/ca.key" ] && { echo "CA déjà présente dans ${PKI}, abandon."; exit 1; }
mkdir -p "${PKI}/issued"

openssl genrsa -out "${PKI}/ca.key" 4096
openssl req -x509 -new -sha256 -days "${DAYS}" \
  -key "${PKI}/ca.key" \
  -subj "/C=FR/O=bencopharma/OU=PoC/CN=bencopharma PoC CA Interne" \
  -out "${PKI}/ca.crt"

echo "CA créée :"
openssl x509 -in "${PKI}/ca.crt" -noout -subject -enddate
