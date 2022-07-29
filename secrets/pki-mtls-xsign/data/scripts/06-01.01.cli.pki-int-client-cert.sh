#!/bin/sh

set -e
set -x

# Create Alice mTLS Server Certificate
vault write pki-int-client/issue/alice-server \
    common_name="zwtf88drtfm01smf01.smf.5gc.mnc88.mcc888.3gppnetwork.org" \
    alt_names="alice.smf.5gc.mnc88.mcc888.3gppnetwork.org" \
    uri_sans="alice.smf.5gc.mnc88.mcc888.3gppnetwork.org" \
    ttl="8h" \
    -format=json | jq > workspace/tmp/alice/intermediate-server.json

# Create Alice mTLS Client Certificate
vault write pki-int-client/issue/bob-client-alice \
    common_name="zwtf88drtfm01smf01.smf.5gc.mnc88.mcc888.3gppnetwork.org" \
    alt_names="alice.smf.5gc.mnc88.mcc888.3gppnetwork.org" \
    uri_sans="alice.smf.5gc.mnc88.mcc888.3gppnetwork.org" \
    ttl="8h" \
    -format=json | jq > workspace/tmp/alice/intermediate-n7-client.json

# Format Alice mTLS Server Certificate
touch workspace/tmp/alice/server.bundle
jq -r '.data.certificate' < workspace/tmp/alice/intermediate-server.json > workspace/tmp/alice/server.certificate
jq -r '.data.private_key' < workspace/tmp/alice/intermediate-server.json > workspace/tmp/alice/server.private_key
jq -r '.data.issuing_ca' < workspace/tmp/alice/intermediate-server.json > workspace/tmp/alice/server.issuing_ca
jq -r '.data.serial_number' < workspace/tmp/alice/intermediate-server.json > workspace/tmp/alice/server.serial_number
cp workspace/tmp/alice/server.bundle workspace/tmp/_archive/alice/server.bundle.$(date +"%Y%m%d-%H%M%S").bak
cat workspace/tmp/alice/server.certificate workspace/tmp/alice/server.issuing_ca workspace/tmp/alice/ca/ca_root.issuing_ca > workspace/tmp/alice/server.bundle

# Format Alice mTLS Client Certificate
touch workspace/tmp/alice/n7-client.bundle
jq -r '.data.certificate' < workspace/tmp/alice/intermediate-n7-client.json > workspace/tmp/alice/n7-client.certificate
jq -r '.data.private_key' < workspace/tmp/alice/intermediate-n7-client.json > workspace/tmp/alice/n7-client.private_key
jq -r '.data.issuing_ca' < workspace/tmp/alice/intermediate-n7-client.json > workspace/tmp/alice/n7-client.issuing_ca
jq -r '.data.serial_number' < workspace/tmp/alice/intermediate-n7-client.json > workspace/tmp/alice/n7-client.serial_number
cp workspace/tmp/alice/n7-client.bundle workspace/tmp/_archive/alice/n7-client.bundle.$(date +"%Y%m%d-%H%M%S").bak
cat workspace/tmp/alice/n7-client.certificate workspace/tmp/alice/n7-client.issuing_ca workspace/tmp/alice/ca/ca_root.issuing_ca > workspace/tmp/alice/n7-client.bundle
