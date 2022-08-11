#!/bin/sh

## 

set -e
set -x

# VARS
export VAULT_ADDR_DOCKER='http://192.168.65.2:18200'
export VAULT_ADDR='http://127.0.0.1:18200'

## GENERATE LEAF CERT - CLIENT
#vault write -format=json pki_int_amf_n15/issue/client common_name="client.n15.carol.amf.5gc.mnc88.mcc888.3gppnetwork.org" > pki_int_amf_n15_client.cert.json
vault write -format=json \
    pki_int_amf_n15/issue/client \
    common_name="client.n15.carol.amf.5gc.mnc88.mcc888.3gppnetwork.org" \
    | tee workspace/tmp/amf/n15/pki_int_amf_n15_client.cert.json

#    alt_names="client.n15.carol.amf.5gc.mobilecarrier.net" \
#    uri_sans="client.n15.carol.amf.5gc.mobilecarrier.net" \

## FORMAT LEAF CERT - CLIENT
#touch workspace/tmp/amf/n15/client.bundle
jq -r '.data.certificate' < workspace/tmp/amf/n15/pki_int_amf_n15_client.cert.json > workspace/tmp/amf/n15/client.pem
jq -r '.data.certificate' < workspace/tmp/amf/n15/pki_int_amf_n15_client.cert.json > workspace/tmp/amf/n15/client_chain.pem
jq -r '.data.ca_chain | join("\n")' < workspace/tmp/amf/n15/pki_int_amf_n15_client.cert.json >> workspace/tmp/amf/n15/client_chain.pem
jq -r '.data.private_key' < workspace/tmp/amf/n15/pki_int_amf_n15_client.cert.json > workspace/tmp/amf/n15/client_key.pem
jq -r '.data.issuing_ca' < workspace/tmp/amf/n15/pki_int_amf_n15_client.cert.json > workspace/tmp/amf/n15/client_issuing_ca.pem
jq -r '.data.serial_number' < workspace/tmp/amf/n15/pki_int_amf_n15_client.cert.json > workspace/tmp/amf/n15/client.serial
cp workspace/tmp/amf/n15/client_chain.pem workspace/tmp/_archive/amf/client_chain.pem.$(date +"%Y%m%d-%H%M%S").bak
#cat workspace/tmp/amf/n15/client.pem workspace/tmp/amf/n15/client_chain.pem > workspace/tmp/amf/n15/client.bundle
#cat workspace/tmp/amf/n15/client.bundle

## GENERATE LEAF CERT - SERVER
#vault write -format=json pki_int_amf_n15/issue/server common_name="server.n15.carol.amf.5gc.mnc88.mcc888.3gppnetwork.org" > pki_int_amf_n15_server.cert.json
vault write -format=json \
    pki_int_amf_n15/issue/server \
    common_name="server.n15.carol.amf.5gc.mnc88.mcc888.3gppnetwork.org" \
    | tee workspace/tmp/amf/n15/pki_int_amf_n15_server.cert.json

#    alt_names="server.n15.carol.amf.5gc.mobilecarrier.net" \
#    uri_sans="server.n15.carol.amf.5gc.mobilecarrier.net" \

## FORMAT LEAF CERT - SERVER
#touch workspace/tmp/amf/n15/server.bundle
jq -r '.data.certificate' < workspace/tmp/amf/n15/pki_int_amf_n15_server.cert.json > workspace/tmp/amf/n15/server.pem
jq -r '.data.certificate' < workspace/tmp/amf/n15/pki_int_amf_n15_server.cert.json > workspace/tmp/amf/n15/server_chain.pem
jq -r '.data.ca_chain | join("\n")' < workspace/tmp/amf/n15/pki_int_amf_n15_server.cert.json >> workspace/tmp/amf/n15/server_chain.pem
jq -r '.data.private_key' < workspace/tmp/amf/n15/pki_int_amf_n15_server.cert.json > workspace/tmp/amf/n15/server_key.pem
jq -r '.data.issuing_ca' < workspace/tmp/amf/n15/pki_int_amf_n15_server.cert.json > workspace/tmp/amf/n15/server_issuing_ca.pem
jq -r '.data.serial_number' < workspace/tmp/amf/n15/pki_int_amf_n15_server.cert.json > workspace/tmp/amf/n15/server.serial
cp workspace/tmp/amf/n15/server_chain.pem workspace/tmp/_archive/amf/server_chain.pem.$(date +"%Y%m%d-%H%M%S").bak
#cat workspace/tmp/amf/n15/server.pem workspace/tmp/amf/n15/server_chain.pem > workspace/tmp/amf/n15/server.bundle
#cat workspace/tmp/amf/n15/server.bundle

#### AMF Intermediate / Publish CA & CRL Endpoints
vault write pki_int_amf_n15/config/urls \
    issuing_certificates="${VAULT_ADDR_DOCKER}/v1/pki_int_amf_n15/ca,${VAULT_ADDR}/v1/pki_int_amf_n15/ca" \
    crl_distribution_points="${VAULT_ADDR_DOCKER}/v1/pki_int_amf_n15/crl,${VAULT_ADDR}/v1/pki_int_amf_n15/crl" \

vault read -format=json pki_int_amf_n15/config/urls > workspace/tmp/amf/n15/pki_int_amf_n15_ca_crl.json
jq < workspace/tmp/amf/n15/pki_int_amf_n15_ca_crl.json
