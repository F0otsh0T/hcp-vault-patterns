#!/bin/sh

## 

set -e
set -x

# VARS
export VAULT_ADDR_DOCKER='http://192.168.65.2:18200'
export VAULT_ADDR='http://127.0.0.1:18200'

## GENERATE LEAF CERT - CLIENT
#vault write -format=json pki_int_smf_server/issue/client common_name="client.bob.smf.5gc.mnc88.mcc888.3gppnetwork.org" > pki_int_smf_server_client.cert.json
vault write -format=json \
    pki_int_smf_server/issue/client \
    common_name="client.bob.smf.5gc.mnc88.mcc888.3gppnetwork.org" \
    | tee workspace/tmp/smf/pki_int_smf_server_client.cert.json

#    alt_names="client.bob.smf.5gc.mobilecarrier.net" \
#    uri_sans="client.bob.smf.5gc.mobilecarrier.net" \

## FORMAT LEAF CERT - CLIENT
#touch workspace/tmp/smf/server/client.bundle
jq -r '.data.certificate' < workspace/tmp/smf/pki_int_smf_server_client.cert.json > workspace/tmp/smf/server/client.pem
jq -r '.data.certificate' < workspace/tmp/smf/pki_int_smf_server_client.cert.json > workspace/tmp/smf/server/client_chain.pem
jq -r '.data.ca_chain | join("\n")' < workspace/tmp/smf/pki_int_smf_server_client.cert.json >> workspace/tmp/smf/server/client_chain.pem
jq -r '.data.private_key' < workspace/tmp/smf/pki_int_smf_server_client.cert.json > workspace/tmp/smf/server/client_key.pem
jq -r '.data.issuing_ca' < workspace/tmp/smf/pki_int_smf_server_client.cert.json > workspace/tmp/smf/server/client_issuing_ca.pem
jq -r '.data.serial_number' < workspace/tmp/smf/pki_int_smf_server_client.cert.json > workspace/tmp/smf/server/client.serial
#cp workspace/tmp/smf/server/client_chain.pem workspace/tmp/_archive/smf/server/client_chain.pem.$(date +"%Y%m%d-%H%M%S").bak
#cat workspace/tmp/smf/server/client.pem workspace/tmp/smf/server/client_chain.pem > workspace/tmp/smf/server/client.bundle
#cat workspace/tmp/smf/server/client.bundle

## GENERATE LEAF CERT - SERVER
#vault write -format=json pki_int_smf_server/issue/server common_name="server.bob.smf.5gc.mnc88.mcc888.3gppnetwork.org" > pki_int_smf_server_server.cert.json
vault write -format=json \
    pki_int_smf_server/issue/server \
    common_name="server.bob.smf.5gc.mnc88.mcc888.3gppnetwork.org" \
    | tee workspace/tmp/smf/pki_int_smf_server_server.cert.json

#    alt_names="server.bob.smf.5gc.mobilecarrier.net" \
#    uri_sans="server.bob.smf.5gc.mobilecarrier.net" \

## FORMAT LEAF CERT - SERVER
#touch workspace/tmp/smf/server/server.bundle
jq -r '.data.certificate' < workspace/tmp/smf/pki_int_smf_server_server.cert.json > workspace/tmp/smf/server/server.pem
jq -r '.data.certificate' < workspace/tmp/smf/pki_int_smf_server_server.cert.json > workspace/tmp/smf/server/server_chain.pem
jq -r '.data.ca_chain | join("\n")' < workspace/tmp/smf/pki_int_smf_server_server.cert.json >> workspace/tmp/smf/server/server_chain.pem
jq -r '.data.private_key' < workspace/tmp/smf/pki_int_smf_server_server.cert.json > workspace/tmp/smf/server/server_key.pem
jq -r '.data.issuing_ca' < workspace/tmp/smf/pki_int_smf_server_server.cert.json > workspace/tmp/smf/server/server_issuing_ca.pem
jq -r '.data.serial_number' < workspace/tmp/smf/pki_int_smf_server_server.cert.json > workspace/tmp/smf/server/server.serial
#cp workspace/tmp/smf/server/server_chain.pem workspace/tmp/_archive/smf/server/server_chain.pem.$(date +"%Y%m%d-%H%M%S").bak
#cat workspace/tmp/smf/server/server.pem workspace/tmp/smf/server/server_chain.pem > workspace/tmp/smf/server/server.bundle
#cat workspace/tmp/smf/server/server.bundle

#### SMF Intermediate / Publish CA & CRL Endpoints
vault write pki_int_smf_server/config/urls \
    issuing_certificates="${VAULT_ADDR_DOCKER}/v1/pki_int_smf_server/ca,${VAULT_ADDR}/v1/pki_int_smf_server/ca" \
    crl_distribution_points="${VAULT_ADDR_DOCKER}/v1/pki_int_smf_server/crl,${VAULT_ADDR}/v1/pki_int_smf_server/crl" \

vault read -format=json pki_int_smf_server/config/urls > workspace/tmp/smf/pki_int_smf_server_ca_crl.json
jq < workspace/tmp/smf/pki_int_smf_server_ca_crl.json
