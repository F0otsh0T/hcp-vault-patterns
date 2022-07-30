#!/bin/sh

set -e
set -x

#vault write -format=json pki-int-client/intermediate/generate/exported \
vault write -format=json pki-int-client/intermediate/generate/internal \
    key_bits="4096" \
    organization="5gc.mnc88.mcc888.3gppnetwork.org" \
    common_name="smf.5gc.mnc88.mcc888.3gppnetwork.org" \
    alt_names="smf.5gc.mnc88.mcc888.3gppnetwork.org" \
    uri_sans="smf.5gc.mnc88.mcc888.3gppnetwork.org" \
    key_ref="$(jq -r '.data.key_id' < workspace/tmp/alice/ca/ca_root.json)" \
    private_key_format="pem" \
    add_basic_constraints=true \
    | jq > workspace/tmp/alice/int/pki-int-client-csr.json
jq -r '.data.csr' < workspace/tmp/alice/int/pki-int-client-csr.json > workspace/tmp/alice/int/pki-int-client.csr
cat workspace/tmp/alice/int/pki-int-client.csr
