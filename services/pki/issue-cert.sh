#!/usr/bin/env bash
set -euo pipefail

PKI="${HOME}/pki"
NAME="${1:?usage: $0 <nom> <fqdn> [san ...]}"
FQDN="${2:?fqdn requis}"
shift 2
DAYS=825
OUT="${PKI}/issued/${NAME}"
umask 077
mkdir -p "${OUT}"

SANS="DNS:${FQDN}"
for san in "$@"; do
  if [[ "$san" =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
    SANS="${SANS},IP:${san}"
  else
    SANS="${SANS},DNS:${san}"
  fi
done

EXTFILE="$(mktemp)"
cat > "${EXTFILE}" <<EOF
subjectAltName = ${SANS}
keyUsage = critical, digitalSignature, keyEncipherment
extendedKeyUsage = serverAuth
basicConstraints = critical, CA:FALSE
EOF

openssl genrsa -out "${OUT}/${NAME}.key" 2048
openssl req -new -sha256 -key "${OUT}/${NAME}.key" \
  -subj "/C=FR/O=bencopharma/OU=PoC/CN=${FQDN}" \
  -out "${OUT}/${NAME}.csr"

openssl x509 -req -sha256 -days "${DAYS}" \
  -in "${OUT}/${NAME}.csr" \
  -CA "${PKI}/ca.crt" -CAkey "${PKI}/ca.key" -CAcreateserial \
  -extfile "${EXTFILE}" \
  -out "${OUT}/${NAME}.crt"

rm -f "${EXTFILE}"
cat "${OUT}/${NAME}.crt" "${PKI}/ca.crt" > "${OUT}/${NAME}-fullchain.crt"
echo "Émis dans ${OUT}/ :"
openssl x509 -in "${OUT}/${NAME}.crt" -noout -subject -ext subjectAltName,extendedKeyUsage -enddate
