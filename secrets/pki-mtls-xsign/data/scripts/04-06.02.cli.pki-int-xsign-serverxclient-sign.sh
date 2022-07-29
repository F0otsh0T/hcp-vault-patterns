#!/bin/sh

set -e
set -x

vault write -format=json pki-root-client/root/sign-intermediate \
    csr=@workspace/tmp/bob/xint/pki-int-xsign-n7-server.csr \
    format=pem_bundle \
    ttl="43800h" \
    | jq > workspace/tmp/bob/xint/pki-int-xsign-n7-server-cert.json

jq -r '.data.certificate' < workspace/tmp/bob/xint/pki-int-xsign-n7-server-cert.json > workspace/tmp/bob/xint/pki-int-xsign-n7-server.pem
