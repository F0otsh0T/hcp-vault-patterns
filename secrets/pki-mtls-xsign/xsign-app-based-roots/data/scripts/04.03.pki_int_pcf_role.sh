#!/bin/sh

## 

set -e
set -x

## SERVER ROLE
#vault write pki_int_pcf/roles/client allow_any_name=true enforce_hostnames=false server_flag=false client_flag=true ttl=28d
vault write -format=json \
    pki_int_pcf/roles/client \
    ttl=72h \
    allow_any_name=true \
    allow_glob_domains=true \
    allowed_subdomains=true \
    enforce_hostnames=false \
    server_flag=false \
    client_flag=true

#    organization="5gc.mnc88.mcc888.3gppnetwork.org" \
#    no_store=true \
#    generate_lease=false \
#    allowed_domains="*.bob.pcf.5gc.mnc88.mcc888.3gppnetwork.org","*.bob.pcf.5gc.mobilecarrier.net" \
#    key_usage="DigitalSignature,KeyEncipherment" \
#    alt_names="*.bob.pcf.5gc.mobilecarrier.net" \
#    allowed_uri_sans="*.bob.pcf.5gc.mobilecarrier.net" \
#    uri_sans="*.bob.pcf.5gc.mobilecarrier.net" \

## CLIENT ROLE
#vault write pki_int_pcf/roles/server allow_any_name=true enforce_hostnames=false server_flag=true client_flag=false ttl=28d
vault write -format=json \
    pki_int_pcf/roles/server \
    ttl=72h \
    allow_any_name=true \
    allow_glob_domains=true \
    allowed_subdomains=true \
    enforce_hostnames=false \
    server_flag=true \
    client_flag=false

#    organization="5gc.mnc88.mcc888.3gppnetwork.org" \
#    no_store=true \
#    generate_lease=false \
#    allowed_domains="*.bob.pcf.5gc.mnc88.mcc888.3gppnetwork.org","*.bob.pcf.5gc.mobilecarrier.net" \
#    key_usage="DigitalSignature" \
#    alt_names="*.bob.pcf.5gc.mobilecarrier.net" \
#    allowed_uri_sans="*.bob.pcf.5gc.mobilecarrier.net" \
#    uri_sans="*.bob.pcf.5gc.mobilecarrier.net" \

vault read -format=json pki_int_pcf/roles/client > workspace/tmp/pcf/role-client.json
jq < workspace/tmp/pcf/role-client.json

vault read -format=json pki_int_pcf/roles/server > workspace/tmp/pcf/role-server.json
jq < workspace/tmp/pcf/role-server.json
