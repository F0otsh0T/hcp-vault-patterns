#!/bin/sh

set -e
set -x

#vault write -format=json pki-root-client/root/generate/internal \
vault write -format=json pki-root-client/root/generate/exported \
    ttl="87600h" \
    key_bits="4096" \
    organization="5gc.mnc88.mcc888.3gppnetwork.org" \
    common_name="smf.5gc.mnc88.mcc888.3gppnetwork.org" \
    issuer_name="pki-root-client-issuer" \
    key_name="pki-root-client-key" \
    private_key_format="pem" \
    max_path_length="2" \
    | jq > workspace/tmp/alice/ca/ca_root.json

jq -r '.data.certificate' < workspace/tmp/alice/ca/ca_root.json > workspace/tmp/alice/ca/CA_cert.crt
jq -r '.data.certificate' < workspace/tmp/alice/ca/ca_root.json > workspace/tmp/alice/ca/ca_root.certificate
jq -r '.data.serial_number' < workspace/tmp/alice/ca/ca_root.json > workspace/tmp/alice/ca/ca_root.serial_number
jq -r '.data.issuing_ca' < workspace/tmp/alice/ca/ca_root.json > workspace/tmp/alice/ca/ca_root.issuing_ca
jq -r '.data.key_id' < workspace/tmp/alice/ca/ca_root.json > workspace/tmp/alice/ca/ca_root.key.id
jq -r '.data.key_name' < workspace/tmp/alice/ca/ca_root.json > workspace/tmp/alice/ca/ca_root.key_name
jq -r '.data.private_key' < workspace/tmp/alice/ca/ca_root.json > workspace/tmp/alice/ca/ca_root.private_key
