#!/bin/sh

set -e
set -x

# Create Bob mTLS Server Certificate
vault write pki-int-server/issue/bob-server \
    common_name="zwtf88drtfm01pcf01.pcf.5gc.mnc88.mcc888.3gppnetwork.org" \
    alt_names="bob.pcf.5gc.mnc88.mcc888.3gppnetwork.org" \
    uri_sans="bob.pcf.5gc.mnc88.mcc888.3gppnetwork.org" \
    ttl="8h" \
    -format=json | jq > workspace/tmp/bob/intermediate-n7-server.json

# Format Bob mTLS Server Certificate
touch workspace/tmp/bob/n7-server.bundle
jq -r '.data.certificate' < workspace/tmp/bob/intermediate-n7-server.json > workspace/tmp/bob/n7-server.certificate
jq -r '.data.private_key' < workspace/tmp/bob/intermediate-n7-server.json > workspace/tmp/bob/n7-server.private_key
jq -r '.data.issuing_ca' < workspace/tmp/bob/intermediate-n7-server.json > workspace/tmp/bob/n7-server.issuing_ca
jq -r '.data.serial_number' < workspace/tmp/bob/intermediate-n7-server.json > workspace/tmp/bob/n7-server.serial_number
cp workspace/tmp/bob/n7-server.bundle workspace/tmp/_archive/bob/n7-server.bundle.$(date +"%Y%m%d-%H%M%S").bak
cat workspace/tmp/bob/n7-server.certificate workspace/tmp/bob/n7-server.issuing_ca workspace/tmp/bob/ca/ca_root.issuing_ca > workspace/tmp/bob/n7-server.bundle
