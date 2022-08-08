#!/bin/sh

## 

set -e
set -x

# VARS
export VAULT_ADDR_DOCKER='http://192.168.65.2:18200'
export VAULT_ADDR='http://127.0.0.1:18200'

## GENERATE LEAF CERT - CLIENT
#vault write -format=json pki_int_nef/issue/client common_name="client.charlie.nef.5gc.mnc88.mcc888.3gppnetwork.org" > pki_int_nef_client.cert.json
vault write -format=json \
    pki_int_nef/issue/client \
    common_name="client.charlie.nef.5gc.mnc88.mcc888.3gppnetwork.org" \
    | tee workspace/tmp/nef/server/pki_int_nef_client.cert.json

#    alt_names="client.charlie.nef.5gc.mobilecarrier.net" \
#    uri_sans="client.charlie.nef.5gc.mobilecarrier.net" \

## FORMAT LEAF CERT - CLIENT
#touch workspace/tmp/nef/server/client.bundle
jq -r '.data.certificate' < workspace/tmp/nef/server/pki_int_nef_client.cert.json > workspace/tmp/nef/server/client.pem
jq -r '.data.certificate' < workspace/tmp/nef/server/pki_int_nef_client.cert.json > workspace/tmp/nef/server/client_chain.pem
jq -r '.data.ca_chain | join("\n")' < workspace/tmp/nef/server/pki_int_nef_client.cert.json >> workspace/tmp/nef/server/client_chain.pem
jq -r '.data.private_key' < workspace/tmp/nef/server/pki_int_nef_client.cert.json > workspace/tmp/nef/server/client_key.pem
jq -r '.data.issuing_ca' < workspace/tmp/nef/server/pki_int_nef_client.cert.json > workspace/tmp/nef/server/client_issuing_ca.pem
jq -r '.data.serial_number' < workspace/tmp/nef/server/pki_int_nef_client.cert.json > workspace/tmp/nef/server/client.serial
cp workspace/tmp/nef/server/client_chain.pem workspace/tmp/_archive/nef/client_chain.pem.$(date +"%Y%m%d-%H%M%S").bak
#cat workspace/tmp/nef/server/client.pem workspace/tmp/nef/server/client_chain.pem > workspace/tmp/nef/server/client.bundle
#cat workspace/tmp/nef/server/client.bundle

## GENERATE LEAF CERT - SERVER
#vault write -format=json pki_int_nef/issue/server common_name="server.charlie.nef.5gc.mnc88.mcc888.3gppnetwork.org" > pki_int_nef_server.cert.json
vault write -format=json \
    pki_int_nef/issue/server \
    common_name="server.charlie.nef.5gc.mnc88.mcc888.3gppnetwork.org" \
    | tee workspace/tmp/nef/server/pki_int_nef_server.cert.json

#    alt_names="server.charlie.nef.5gc.mobilecarrier.net" \
#    uri_sans="server.charlie.nef.5gc.mobilecarrier.net" \

## FORMAT LEAF CERT - SERVER
#touch workspace/tmp/nef/server/server.bundle
jq -r '.data.certificate' < workspace/tmp/nef/server/pki_int_nef_server.cert.json > workspace/tmp/nef/server/server.pem
jq -r '.data.certificate' < workspace/tmp/nef/server/pki_int_nef_server.cert.json > workspace/tmp/nef/server/server_chain.pem
jq -r '.data.ca_chain | join("\n")' < workspace/tmp/nef/server/pki_int_nef_server.cert.json >> workspace/tmp/nef/server/server_chain.pem
jq -r '.data.private_key' < workspace/tmp/nef/server/pki_int_nef_server.cert.json > workspace/tmp/nef/server/server_key.pem
jq -r '.data.issuing_ca' < workspace/tmp/nef/server/pki_int_nef_server.cert.json > workspace/tmp/nef/server/server_issuing_ca.pem
jq -r '.data.serial_number' < workspace/tmp/nef/server/pki_int_nef_server.cert.json > workspace/tmp/nef/server/server.serial
cp workspace/tmp/nef/server/server_chain.pem workspace/tmp/_archive/nef/server_chain.pem.$(date +"%Y%m%d-%H%M%S").bak
#cat workspace/tmp/nef/server/server.pem workspace/tmp/nef/server/server_chain.pem > workspace/tmp/nef/server/server.bundle
#cat workspace/tmp/nef/server/server.bundle

#### NEF Intermediate / Publish CA & CRL Endpoints
vault write pki_int_nef/config/urls \
    issuing_certificates="${VAULT_ADDR_DOCKER}/v1/pki_int_nef/ca,${VAULT_ADDR}/v1/pki_int_nef/ca" \
    crl_distribution_points="${VAULT_ADDR_DOCKER}/v1/pki_int_nef/crl,${VAULT_ADDR}/v1/pki_int_nef/crl" \

vault read -format=json pki_int_nef/config/urls > workspace/tmp/nef/server/pki_int_ca_crl.json
jq < workspace/tmp/nef/server/pki_int_ca_crl.json
