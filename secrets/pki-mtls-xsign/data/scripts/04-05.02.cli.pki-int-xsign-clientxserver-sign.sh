#!/bin/sh

set -e
set -x

vault write -format=json pki-root-server/root/sign-intermediate \
    csr=@workspace/tmp/alice/xint/pki-int-xsign-n7-client.csr \
    format=pem_bundle \
    ttl="43800h" \
    | jq > workspace/tmp/alice/xint/pki-int-xsign-n7-client-cert.json

jq -r '.data.certificate' < workspace/tmp/alice/xint/pki-int-xsign-n7-client-cert.json > workspace/tmp/alice/xint/pki-int-xsign-n7-client.pem
