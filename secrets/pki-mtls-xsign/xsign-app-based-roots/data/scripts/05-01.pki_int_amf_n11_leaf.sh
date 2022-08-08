#!/bin/sh

## 

set -e
set -x

# VARS
export VAULT_ADDR_DOCKER='http://192.168.65.2:18200'
export VAULT_ADDR='http://127.0.0.1:18200'

## GENERATE LEAF CERT - CLIENT
#vault write -format=json pki_int_amf_n11/issue/client common_name="client.n11.carol.amf.5gc.mnc88.mcc888.3gppnetwork.org" > pki_int_amf_n11_client.cert.json
vault write -format=json \
    pki_int_amf_n11/issue/client \
    common_name="client.n11.carol.amf.5gc.mnc88.mcc888.3gppnetwork.org" \
    | tee workspace/tmp/amf/n11/pki_int_amf_n11_client.cert.json

#    alt_names="client.n11.carol.amf.5gc.mobilecarrier.net" \
#    uri_sans="client.n11.carol.amf.5gc.mobilecarrier.net" \

## FORMAT LEAF CERT - CLIENT
#touch workspace/tmp/amf/n11/client.bundle
jq -r '.data.certificate' < workspace/tmp/amf/n11/pki_int_amf_n11_client.cert.json > workspace/tmp/amf/n11/client.pem
jq -r '.data.certificate' < workspace/tmp/amf/n11/pki_int_amf_n11_client.cert.json > workspace/tmp/amf/n11/client_chain.pem
jq -r '.data.ca_chain | join("\n")' < workspace/tmp/amf/n11/pki_int_amf_n11_client.cert.json >> workspace/tmp/amf/n11/client_chain.pem
jq -r '.data.private_key' < workspace/tmp/amf/n11/pki_int_amf_n11_client.cert.json > workspace/tmp/amf/n11/client_key.pem
jq -r '.data.issuing_ca' < workspace/tmp/amf/n11/pki_int_amf_n11_client.cert.json > workspace/tmp/amf/n11/client_issuing_ca.pem
jq -r '.data.serial_number' < workspace/tmp/amf/n11/pki_int_amf_n11_client.cert.json > workspace/tmp/amf/n11/client.serial
cp workspace/tmp/amf/n11/client_chain.pem workspace/tmp/_archive/amf/client_chain.pem.$(date +"%Y%m%d-%H%M%S").bak
#cat workspace/tmp/amf/n11/client.pem workspace/tmp/amf/n11/client_chain.pem > workspace/tmp/amf/n11/client.bundle
#cat workspace/tmp/amf/n11/client.bundle

## GENERATE LEAF CERT - SERVER
#vault write -format=json pki_int_amf_n11/issue/server common_name="server.n11.carol.amf.5gc.mnc88.mcc888.3gppnetwork.org" > pki_int_amf_n11_server.cert.json
vault write -format=json \
    pki_int_amf_n11/issue/server \
    common_name="server.n11.carol.amf.5gc.mnc88.mcc888.3gppnetwork.org" \
    | tee workspace/tmp/amf/n11/pki_int_amf_n11_server.cert.json

#    alt_names="server.n11.carol.amf.5gc.mobilecarrier.net" \
#    uri_sans="server.n11.carol.amf.5gc.mobilecarrier.net" \

## FORMAT LEAF CERT - SERVER
#touch workspace/tmp/amf/n11/server.bundle
jq -r '.data.certificate' < workspace/tmp/amf/n11/pki_int_amf_n11_server.cert.json > workspace/tmp/amf/n11/server.pem
jq -r '.data.certificate' < workspace/tmp/amf/n11/pki_int_amf_n11_server.cert.json > workspace/tmp/amf/n11/server_chain.pem
jq -r '.data.ca_chain | join("\n")' < workspace/tmp/amf/n11/pki_int_amf_n11_server.cert.json >> workspace/tmp/amf/n11/server_chain.pem
jq -r '.data.private_key' < workspace/tmp/amf/n11/pki_int_amf_n11_server.cert.json > workspace/tmp/amf/n11/server_key.pem
jq -r '.data.issuing_ca' < workspace/tmp/amf/n11/pki_int_amf_n11_server.cert.json > workspace/tmp/amf/n11/server_issuing_ca.pem
jq -r '.data.serial_number' < workspace/tmp/amf/n11/pki_int_amf_n11_server.cert.json > workspace/tmp/amf/n11/server.serial
cp workspace/tmp/amf/n11/server_chain.pem workspace/tmp/_archive/amf/server_chain.pem.$(date +"%Y%m%d-%H%M%S").bak
#cat workspace/tmp/amf/n11/server.pem workspace/tmp/amf/n11/server_chain.pem > workspace/tmp/amf/n11/server.bundle
#cat workspace/tmp/amf/n11/server.bundle

#### AMF Intermediate / Publish CA & CRL Endpoints
vault write pki_int_amf_n11/config/urls \
    issuing_certificates="${VAULT_ADDR_DOCKER}/v1/pki_int_amf_n11/ca,${VAULT_ADDR}/v1/pki_int_amf_n11/ca" \
    crl_distribution_points="${VAULT_ADDR_DOCKER}/v1/pki_int_amf_n11/crl,${VAULT_ADDR}/v1/pki_int_amf_n11/crl" \

vault read -format=json pki_int_amf_n11/config/urls > workspace/tmp/amf/n11/pki_int_amf_n11_ca_crl.json
jq < workspace/tmp/amf/n11/pki_int_amf_n11_ca_crl.json
