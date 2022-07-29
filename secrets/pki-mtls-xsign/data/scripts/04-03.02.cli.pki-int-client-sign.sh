#!/bin/sh

set -e
set -x

vault write -format=json pki-root-client/root/sign-intermediate \
    csr=@workspace/tmp/alice/int/pki-int-client.csr \
    format=pem_bundle \
    ttl="43800h" \
    | jq > workspace/tmp/alice/int/pki-int-client-cert.json

jq -r '.data.certificate' < workspace/tmp/alice/int/pki-int-client-cert.json > workspace/tmp/alice/int/pki-int-client.pem
