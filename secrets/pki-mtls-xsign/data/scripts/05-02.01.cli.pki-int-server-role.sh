#!/bin/sh

set -e
set -x

# Create Bob mTLS Server Role
vault write pki-int-server/roles/bob-server \
    max_ttl="720h" \
    server_flag=true \
    client_flag=false \
    allow_glob_domains=true \
    no_store=true \
    generate_lease=false \
    allowed_domains="*.pcf.5gc.mnc88.mcc888.3gppnetwork.org" \
    allowed_subdomains=true \
    organization="5gc.mnc88.mcc888.3gppnetwork.org" \
    key_usage="DigitalSignature,KeyEncipherment" \
    alt_names="*.pcf.5gc.mnc88.mcc888.3gppnetwork.org" \
    allowed_uri_sans="*.pcf.5gc.mnc88.mcc888.3gppnetwork.org" \
    uri_sans="*.pcf.5gc.mnc88.mcc888.3gppnetwork.org"

vault read -format=json pki-int-server/roles/bob-server > workspace/tmp/bob/pki-int-server-role-bob-server.json
jq < workspace/tmp/bob/pki-int-server-role-bob-server.json
