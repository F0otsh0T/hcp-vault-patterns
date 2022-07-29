#!/bin/sh

set -e
set -x

# Create Alice mTLS Server Role
vault write pki-int-client/roles/alice-server \
    max_ttl="720h" \
    server_flag=true \
    client_flag=false \
    allow_glob_domains=true \
    no_store=true \
    generate_lease=false \
    allowed_domains="*.smf.5gc.mnc88.mcc888.3gppnetwork.org" \
    allowed_subdomains=true \
    organization="5gc.mnc88.mcc888.3gppnetwork.org" \
    key_usage="DigitalSignature,KeyEncipherment" \
    alt_names="*.smf.5gc.mnc88.mcc888.3gppnetwork.org" \
    allowed_uri_sans="*.smf.5gc.mnc88.mcc888.3gppnetwork.org" \
    uri_sans="*.smf.5gc.mnc88.mcc888.3gppnetwork.org"

vault read -format=json pki-int-client/roles/alice-server > workspace/tmp/alice/pki-int-client-role-alice-server.json
jq < workspace/tmp/alice/pki-int-client-role-alice-server.json

# Create Alice mTLS Client Role
vault write pki-int-client/roles/bob-client-alice \
    max_ttl="720h" \
    server_flag=false \
    client_flag=true \
    allow_glob_domains=true \
    no_store=true \
    generate_lease=false \
    allowed_domains="*.smf.5gc.mnc88.mcc888.3gppnetwork.org" \
    allowed_subdomains=true \
    organization="5gc.mnc88.mcc888.3gppnetwork.org" \
    key_usage="DigitalSignature" \
    alt_names="*.smf.5gc.mnc88.mcc888.3gppnetwork.org" \
    allowed_uri_sans="*.5gc.mnc88.mcc888.3gppnetwork.org" \
    uri_sans="*.smf.5gc.mnc88.mcc888.3gppnetwork.org"

vault read -format=json pki-int-client/roles/bob-client-alice > workspace/tmp/alice/pki-int-client-role-bob-client-alice.json
jq < workspace/tmp/alice/pki-int-client-role-bob-client-alice.json