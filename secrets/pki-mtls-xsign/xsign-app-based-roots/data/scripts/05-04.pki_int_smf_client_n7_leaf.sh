#!/bin/sh

## 

set -e
set -x

# VARS
export VAULT_ADDR_DOCKER='http://192.168.65.2:18200'
export VAULT_ADDR='http://127.0.0.1:18200'

## GENERATE LEAF CERT - CLIENT
#vault write -format=json pki_int_smf_client_n7/issue/client common_name="client.alice.smf.5gc.mnc88.mcc888.3gppnetwork.org" > pki_int_smf_client_n7_client.cert.json
vault write -format=json \
    pki_int_smf_client_n7/issue/client \
    common_name="client.alice.smf.5gc.mnc88.mcc888.3gppnetwork.org" \
    | tee workspace/tmp/smf/pki_int_smf_client_n7_client.cert.json

#    alt_names="client.alice.smf.5gc.mobilecarrier.net" \
#    uri_sans="client.alice.smf.5gc.mobilecarrier.net" \

## FORMAT LEAF CERT - CLIENT
#touch workspace/tmp/smf/client_n7/client.bundle
jq -r '.data.certificate' < workspace/tmp/smf/pki_int_smf_client_n7_client.cert.json > workspace/tmp/smf/client_n7/client.pem
jq -r '.data.certificate' < workspace/tmp/smf/pki_int_smf_client_n7_client.cert.json > workspace/tmp/smf/client_n7/client_chain.pem
jq -r '.data.ca_chain | join("\n")' < workspace/tmp/smf/pki_int_smf_client_n7_client.cert.json >> workspace/tmp/smf/client_n7/client_chain.pem
jq -r '.data.private_key' < workspace/tmp/smf/pki_int_smf_client_n7_client.cert.json > workspace/tmp/smf/client_n7/client_key.pem
jq -r '.data.issuing_ca' < workspace/tmp/smf/pki_int_smf_client_n7_client.cert.json > workspace/tmp/smf/client_n7/client_issuing_ca.pem
jq -r '.data.serial_number' < workspace/tmp/smf/pki_int_smf_client_n7_client.cert.json > workspace/tmp/smf/client_n7/client.serial
#cp workspace/tmp/smf/client_n7/client_chain.pem workspace/tmp/_archive/smf/client_n7/client_chain.pem.$(date +"%Y%m%d-%H%M%S").bak
#cat workspace/tmp/smf/client_n7/client.pem workspace/tmp/smf/client_n7/client_chain.pem > workspace/tmp/smf/client_n7/client.bundle
#cat workspace/tmp/smf/client_n7/client.bundle

## GENERATE LEAF CERT - SERVER
#vault write -format=json pki_int_smf_client_n7/issue/server common_name="server.alice.smf.5gc.mnc88.mcc888.3gppnetwork.org" > pki_int_smf_client_n7_server.cert.json
vault write -format=json \
    pki_int_smf_client_n7/issue/server \
    common_name="server.alice.smf.5gc.mnc88.mcc888.3gppnetwork.org" \
    | tee workspace/tmp/smf/pki_int_smf_client_n7_server.cert.json

   alt_names="server.alice.smf.5gc.mobilecarrier.net" \
   uri_sans="server.alice.smf.5gc.mobilecarrier.net" \

## FORMAT LEAF CERT - SERVER
#touch workspace/tmp/smf/client_n7/server.bundle
jq -r '.data.certificate' < workspace/tmp/smf/pki_int_smf_client_n7_server.cert.json > workspace/tmp/smf/client_n7/server.pem
jq -r '.data.certificate' < workspace/tmp/smf/pki_int_smf_client_n7_server.cert.json > workspace/tmp/smf/client_n7/server_chain.pem
jq -r '.data.ca_chain | join("\n")' < workspace/tmp/smf/pki_int_smf_client_n7_server.cert.json >> workspace/tmp/smf/client_n7/server_chain.pem
jq -r '.data.private_key' < workspace/tmp/smf/pki_int_smf_client_n7_server.cert.json > workspace/tmp/smf/client_n7/server_key.pem
jq -r '.data.issuing_ca' < workspace/tmp/smf/pki_int_smf_client_n7_server.cert.json > workspace/tmp/smf/client_n7/server_issuing_ca.pem
jq -r '.data.serial_number' < workspace/tmp/smf/pki_int_smf_client_n7_server.cert.json > workspace/tmp/smf/client_n7/server.serial
#cp workspace/tmp/smf/client_n7/server_chain.pem workspace/tmp/_archive/smf/client_n7/server_chain.pem.$(date +"%Y%m%d-%H%M%S").bak
#cat workspace/tmp/smf/client_n7/server.pem workspace/tmp/smf/client_n7/server_chain.pem > workspace/tmp/smf/client_n7/server.bundle
#cat workspace/tmp/smf/client_n7/server.bundle

#### SMF Intermediate / Publish CA & CRL Endpoints
vault write pki_int_smf_client_n7/config/urls \
    issuing_certificates="${VAULT_ADDR_DOCKER}/v1/pki_int_smf_client_n7/ca,${VAULT_ADDR}/v1/pki_int_smf_client_n7/ca" \
    crl_distribution_points="${VAULT_ADDR_DOCKER}/v1/pki_int_smf_client_n7/crl,${VAULT_ADDR}/v1/pki_int_smf_client_n7/crl" \

vault read -format=json pki_int_smf_client_n7/config/urls > workspace/tmp/smf/pki_int_smf_client_n7_ca_crl.json
jq < workspace/tmp/smf/pki_int_smf_client_n7_ca_crl.json
