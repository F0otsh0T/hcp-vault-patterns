#!/bin/sh

set -e
set -x

vault write -format=json pki-root-server/root/sign-intermediate \
    csr=@workspace/tmp/bob/int/pki-int-server.csr \
    format=pem_bundle \
    ttl="43800h" \
    | jq > workspace/tmp/bob/int/pki-int-server-cert.json

jq -r '.data.certificate' < workspace/tmp/bob/int/pki-int-server-cert.json > workspace/tmp/bob/int/pki-int-server.pem
