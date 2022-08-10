#!/bin/sh

## 

set -e
set -x

## CLIENT ROLE
#vault write amf_int_n11/roles/client allow_any_name=true enforce_hostnames=false server_flag=false client_flag=true ttl=28d
vault write -format=json \
    amf_int_n11/roles/client \
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
#    allowed_domains="*.carol.amf.5gc.mnc88.mcc888.3gppnetwork.org","*.carol.amf.5gc.mobilecarrier.net" \
#    key_usage="DigitalSignature,KeyEncipherment" \
#    alt_names="*.carol.amf.5gc.mobilecarrier.net" \
#    allowed_uri_sans="*.carol.amf.5gc.mobilecarrier.net" \
#    uri_sans="*.carol.amf.5gc.mobilecarrier.net" \

## SERVER ROLE
#vault write amf_int_n11/roles/server allow_any_name=true enforce_hostnames=false server_flag=true client_flag=false ttl=28d
vault write -format=json \
    amf_int_n11/roles/server \
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
#    allowed_domains="*.carol.amf.5gc.mnc88.mcc888.3gppnetwork.org","*.carol.amf.5gc.mobilecarrier.net" \
#    key_usage="DigitalSignature" \
#    alt_names="*.carol.amf.5gc.mobilecarrier.net" \
#    allowed_uri_sans="*.carol.amf.5gc.mobilecarrier.net" \
#    uri_sans="*.carol.amf.5gc.mobilecarrier.net" \


vault read -format=json amf_int_n11/roles/client > workspace/tmp/amf/client-n11/role-client.json
jq < workspace/tmp/amf/client-n11/role-client.json

vault read -format=json amf_int_n11/roles/server > workspace/tmp/amf/client-n11/role-server.json
jq < workspace/tmp/amf/client-n11/role-server.json