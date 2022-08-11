#!/bin/sh

## 

set -e
set -x

# VARS
export VAULT_ADDR_DOCKER='http://192.168.65.2:18200'
export VAULT_ADDR='http://127.0.0.1:18200'

## AMF Int
vault secrets enable -path=pki_int_amf_client_n11 pki
vault secrets tune -max-lease-ttl=2160h pki_int_amf_client_n11

## AMF CSR, Sign, Import
vault write pki_int_amf_client_n11/issuers/import/bundle pem_bundle="$(vault write -field=certificate -format=json pki_root_amf/issuer/default/sign-intermediate  csr="$(vault write -field=csr pki_int_amf_client_n11/intermediate/generate/internal common_name="carol.amf.5gc.mnc88.mcc888.3gppnetwork.org" max_path_length=0 )" | jq -r '.')"
vault write pki_int_amf_client_n11/issuer/default issuer_name="pki_int_amf_client_n11"

##### AMF Int / CSR
#vault write -format=json pki_int_amf_client_n11/intermediate/generate/internal \
#    common_name="carol.amf.5gc.mnc88.mcc888.3gppnetwork.org" \
#    max_path_length=0 \
#    | tee workspace/tmp/amf/pki_int_amf_client_n11.csr.json
##    ttl=2160h \
##    organization="5gc.mnc88.mcc888.3gppnetwork.org" \
#jq < workspace/tmp/amf/pki_int_amf_client_n11.csr.json
#jq -r '.data.csr' < workspace/tmp/amf/pki_int_amf_client_n11.csr.json > workspace/tmp/amf/pki_int_amf_client_n11.csr

##### AMF Int / Root Sign CSR
#vault write -format=json pki_root_amf/issuer/default/sign-intermediate \
#    csr="$(jq -r '.data.csr' < workspace/tmp/amf/pki_int_amf_client_n11.csr.json)" \
#    | tee workspace/tmp/amf/pki_int_amf_client_n11.cert.json
#jq < workspace/tmp/amf/pki_int_amf_client_n11.cert.json
#jq -r '.data.certificate' < workspace/tmp/amf/pki_int_amf_client_n11.cert.json > workspace/tmp/amf/pki_int_amf_client_n11.pem

##### AMF Int / Import Root Signed PEM
#vault write -format=json pki_int_amf_client_n11/issuers/import/bundle \
#    pem_bundle="$(jq -r '.data.certificate' < workspace/tmp/amf/pki_int_amf_client_n11.cert.json)" \
#    | tee workspace/tmp/amf/pki_int_amf_client_n11.import.json
##    pem_bundle="$(jq -r '.data.ca_chain' < workspace/tmp/amf/pki_int_amf_client_n11.cert.json)" \
#jq < workspace/tmp/amf/pki_int_amf_client_n11.import.json

##### AMF Int / Update Issuer
#vault write -format=json pki_int_amf_client_n11/issuer/default \
#    issuer_name="pki_int_amf_client_n11" \
#    | tee workspace/tmp/amf/pki_int_amf_client_n11.issuer.json
#jq < workspace/tmp/amf/pki_int_amf_client_n11.issuer.json

#### AMF Int / Publish CA & CRL Endpoints
vault write pki_int_amf_client_n11/config/urls \
    issuing_certificates="${VAULT_ADDR_DOCKER}/v1/pki_int_amf_client_n11/ca,${VAULT_ADDR}/v1/pki_int_amf_client_n11/ca" \
    crl_distribution_points="${VAULT_ADDR_DOCKER}/v1/pki_int_amf_client_n11/crl,${VAULT_ADDR}/v1/pki_int_amf_client_n11/crl"
