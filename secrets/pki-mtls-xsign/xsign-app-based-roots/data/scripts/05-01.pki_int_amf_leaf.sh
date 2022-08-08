#!/bin/sh

## 

set -e
set -x

# VARS
export VAULT_ADDR_DOCKER='http://192.168.65.2:18200'
export VAULT_ADDR='http://127.0.0.1:18200'

## GENERATE LEAF CERT - CLIENT
#vault write -format=json pki_int_amf/issue/client common_name="client.carol.amf.5gc.mnc88.mcc888.3gppnetwork.org" > pki_int_amf_client.cert.json
vault write -format=json \
    pki_int_amf/issue/client \
    common_name="client.carol.amf.5gc.mnc88.mcc888.3gppnetwork.org" \
    | tee workspace/tmp/amf/server/pki_int_amf_client.cert.json

#    alt_names="client.carol.amf.5gc.mobilecarrier.net" \
#    uri_sans="client.carol.amf.5gc.mobilecarrier.net" \

## FORMAT LEAF CERT - CLIENT
#touch workspace/tmp/amf/server/client.bundle
jq -r '.data.certificate' < workspace/tmp/amf/server/pki_int_amf_client.cert.json > workspace/tmp/amf/server/client.pem
jq -r '.data.certificate' < workspace/tmp/amf/server/pki_int_amf_client.cert.json > workspace/tmp/amf/server/client_chain.pem
jq -r '.data.ca_chain | join("\n")' < workspace/tmp/amf/server/pki_int_amf_client.cert.json >> workspace/tmp/amf/server/client_chain.pem
jq -r '.data.private_key' < workspace/tmp/amf/server/pki_int_amf_client.cert.json > workspace/tmp/amf/server/client_key.pem
jq -r '.data.issuing_ca' < workspace/tmp/amf/server/pki_int_amf_client.cert.json > workspace/tmp/amf/server/client_issuing_ca.pem
jq -r '.data.serial_number' < workspace/tmp/amf/server/pki_int_amf_client.cert.json > workspace/tmp/amf/server/client.serial
cp workspace/tmp/amf/server/client_chain.pem workspace/tmp/_archive/amf/client_chain.pem.$(date +"%Y%m%d-%H%M%S").bak
#cat workspace/tmp/amf/server/client.pem workspace/tmp/amf/server/client_chain.pem > workspace/tmp/amf/server/client.bundle
#cat workspace/tmp/amf/server/client.bundle

## GENERATE LEAF CERT - SERVER
#vault write -format=json pki_int_amf/issue/server common_name="server.carol.amf.5gc.mnc88.mcc888.3gppnetwork.org" > pki_int_amf_server.cert.json
vault write -format=json \
    pki_int_amf/issue/server \
    common_name="server.carol.amf.5gc.mnc88.mcc888.3gppnetwork.org" \
    | tee workspace/tmp/amf/server/pki_int_amf_server.cert.json

#    alt_names="server.carol.amf.5gc.mobilecarrier.net" \
#    uri_sans="server.carol.amf.5gc.mobilecarrier.net" \

## FORMAT LEAF CERT - SERVER
#touch workspace/tmp/amf/server/server.bundle
jq -r '.data.certificate' < workspace/tmp/amf/server/pki_int_amf_server.cert.json > workspace/tmp/amf/server/server.pem
jq -r '.data.certificate' < workspace/tmp/amf/server/pki_int_amf_server.cert.json > workspace/tmp/amf/server/server_chain.pem
jq -r '.data.ca_chain | join("\n")' < workspace/tmp/amf/server/pki_int_amf_server.cert.json >> workspace/tmp/amf/server/server_chain.pem
jq -r '.data.private_key' < workspace/tmp/amf/server/pki_int_amf_server.cert.json > workspace/tmp/amf/server/server_key.pem
jq -r '.data.issuing_ca' < workspace/tmp/amf/server/pki_int_amf_server.cert.json > workspace/tmp/amf/server/server_issuing_ca.pem
jq -r '.data.serial_number' < workspace/tmp/amf/server/pki_int_amf_server.cert.json > workspace/tmp/amf/server/server.serial
cp workspace/tmp/amf/server/server_chain.pem workspace/tmp/_archive/amf/server_chain.pem.$(date +"%Y%m%d-%H%M%S").bak
#cat workspace/tmp/amf/server/server.pem workspace/tmp/amf/server/server_chain.pem > workspace/tmp/amf/server/server.bundle
#cat workspace/tmp/amf/server/server.bundle

#### AMF Intermediate / Publish CA & CRL Endpoints
vault write pki_int_amf/config/urls \
    issuing_certificates="${VAULT_ADDR_DOCKER}/v1/pki_int_amf/ca,${VAULT_ADDR}/v1/pki_int_amf/ca" \
    crl_distribution_points="${VAULT_ADDR_DOCKER}/v1/pki_int_amf/crl,${VAULT_ADDR}/v1/pki_int_amf/crl" \

vault read -format=json pki_int_amf/config/urls > workspace/tmp/amf/server/pki_int_amf_ca_crl.json
jq < workspace/tmp/amf/server/pki_int_amf_ca_crl.json
