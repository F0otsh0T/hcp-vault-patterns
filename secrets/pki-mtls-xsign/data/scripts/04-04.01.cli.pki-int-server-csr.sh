#!/bin/sh

set -e
set -x

#vault write -format=json pki-int-server/intermediate/generate/exported \
vault write -format=json pki-int-server/intermediate/generate/internal \
    key_bits="4096" \
    organization="5gc.mnc88.mcc888.3gppnetwork.org" \
    common_name="pcf.5gc.mnc88.mcc888.3gppnetwork.org" \
    alt_names="pcf.5gc.mnc88.mcc888.3gppnetwork.org" \
    uri_sans="pcf.5gc.mnc88.mcc888.3gppnetwork.org" \
    key_ref="$(jq -r '.data.key_id' < workspace/tmp/bob/ca/ca_root.json)" \
    private_key_format="pem" \
    | jq > workspace/tmp/bob/int/pki-int-server-csr.json
jq -r '.data.csr' < workspace/tmp/bob/int/pki-int-server-csr.json > workspace/tmp/bob/int/pki-int-server.csr
cat workspace/tmp/bob/int/pki-int-server.csr
