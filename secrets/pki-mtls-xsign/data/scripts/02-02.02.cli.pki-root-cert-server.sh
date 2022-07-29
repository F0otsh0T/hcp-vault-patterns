#!/bin/sh

set -e
set -x

#vault write -format=json pki-root-client/root/generate/internal \
vault write -format=json pki-root-server/root/generate/exported \
    ttl="87600h" \
    key_bits="4096" \
    organization="5gc.mnc88.mcc888.3gppnetwork.org" \
    common_name="pcf.5gc.mnc88.mcc888.3gppnetwork.org" \
    issuer_name="pki-root-server-issuer" \
    key_name="pki-root-server-key" \
    private_key_format="pem" \
    max_path_length="2" \
    | jq > workspace/tmp/bob/ca/ca_root.json

jq -r '.data.certificate' < workspace/tmp/bob/ca/ca_root.json > workspace/tmp/bob/ca/CA_cert.crt
jq -r '.data.certificate' < workspace/tmp/bob/ca/ca_root.json > workspace/tmp/bob/ca/ca_root.certificate
jq -r '.data.serial_number' < workspace/tmp/bob/ca/ca_root.json > workspace/tmp/bob/ca/ca_root.serial_number
jq -r '.data.issuing_ca' < workspace/tmp/bob/ca/ca_root.json > workspace/tmp/bob/ca/ca_root.issuing_ca
jq -r '.data.key_id' < workspace/tmp/bob/ca/ca_root.json > workspace/tmp/bob/ca/ca_root.key.id
jq -r '.data.key_name' < workspace/tmp/bob/ca/ca_root.json > workspace/tmp/bob/ca/ca_root.key_name
jq -r '.data.private_key' < workspace/tmp/bob/ca/ca_root.json > workspace/tmp/bob/ca/ca_root.private_key
