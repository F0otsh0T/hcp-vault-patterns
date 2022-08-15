#!/bin/sh

## 

set -e
set -x

## CLIENT ROLE
#vault write pcf_int_n15/roles/client allow_any_name=true enforce_hostnames=false server_flag=false client_flag=true ttl=28d
vault write -format=json \
    pcf_int_n15/roles/client \
    ttl=72h \
    allow_any_name=true \
    allow_glob_domains=true \
    allow_subdomains=true \
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

## SERVER ROLE
#vault write pcf_int_n15/roles/server allow_any_name=true enforce_hostnames=false server_flag=true client_flag=false ttl=28d
vault write -format=json \
    pcf_int_n15/roles/server \
    ttl=72h \
    allow_any_name=true \
    allow_glob_domains=true \
    allow_subdomains=true \
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

vault read -format=json pcf_int_n15/roles/client > workspace/tmp/pcf/server-n15/role-client.json
jq < workspace/tmp/pcf/server-n15/role-client.json

vault read -format=json pcf_int_n15/roles/server > workspace/tmp/pcf/server-n15/role-server.json
jq < workspace/tmp/pcf/server-n15/role-server.json
