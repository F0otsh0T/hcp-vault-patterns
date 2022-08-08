#!/bin/sh

## 

set -e
set -x

# VARS
export VAULT_ADDR_DOCKER='http://192.168.65.2:18200'
export VAULT_ADDR='http://127.0.0.1:18200'

## NEF Int
vault secrets enable -path=pki_int_nef_n29 pki
vault secrets tune -max-lease-ttl=2160h pki_int_nef_n29

## NEF CSR, Sign, Import
vault write pki_int_nef_n29/issuers/import/bundle pem_bundle="$(vault write -field=certificate -format=json pki_root_nef/issuer/default/sign-intermediate  csr="$(vault write -field=csr pki_int_nef_n29/intermediate/generate/internal common_name="charlie.nef.5gc.mnc88.mcc888.3gppnetwork.org" max_path_length=0 )" | jq -r '.')"
vault write pki_int_nef_n29/issuer/default issuer_name="pki_int_nef_n29"

##### NEF Int / CSR
#vault write -format=json pki_int_nef_n29/intermediate/generate/internal \
#    common_name="charlie.nef.5gc.mnc88.mcc888.3gppnetwork.org" \
#    max_path_length=0 \
#    | tee workspace/tmp/nef/pki_int_nef_n29.csr.json
##    ttl=2160h \
##    organization="5gc.mnc88.mcc888.3gppnetwork.org" \
#jq < workspace/tmp/nef/pki_int_nef_n29.csr.json
#jq -r '.data.csr' < workspace/tmp/nef/pki_int_nef_n29.csr.json > workspace/tmp/nef/pki_int_nef_n29.csr

##### NEF Int / Root Sign CSR
#vault write -format=json pki_root_nef/issuer/default/sign-intermediate \
#    csr="$(jq -r '.data.csr' < workspace/tmp/nef/pki_int_nef_n29.csr.json)" \
#    | tee workspace/tmp/nef/pki_int_nef_n29.cert.json
#jq < workspace/tmp/nef/pki_int_nef_n29.cert.json
#jq -r '.data.certificate' < workspace/tmp/nef/pki_int_nef_n29.cert.json > workspace/tmp/nef/pki_int_nef_n29.pem

##### NEF Int / Import Root Signed PEM
#vault write -format=json pki_int_nef_n29/issuers/import/bundle \
#    pem_bundle="$(jq -r '.data.certificate' < workspace/tmp/nef/pki_int_nef_n29.cert.json)" \
#    | tee workspace/tmp/nef/pki_int_nef_n29.import.json
##    pem_bundle="$(jq -r '.data.ca_chain' < workspace/tmp/nef/pki_int_nef_n29.cert.json)" \
#jq < workspace/tmp/nef/pki_int_nef_n29.import.json

##### NEF Int / Update Issuer
#vault write -format=json pki_int_nef_n29/issuer/default \
#    issuer_name="pki_int_nef_n29" \
#    | tee workspace/tmp/nef/pki_int_nef_n29.issuer.json
#jq < workspace/tmp/nef/pki_int_nef_n29.issuer.json

#### NEF Int / Publish CA & CRL Endpoints
vault write pki_int_nef_n29/config/urls \
    issuing_certificates="${VAULT_ADDR_DOCKER}/v1/pki_int_nef_n29/ca,${VAULT_ADDR}/v1/pki_int_nef_n29/ca" \
    crl_distribution_points="${VAULT_ADDR_DOCKER}/v1/pki_int_nef_n29/crl,${VAULT_ADDR}/v1/pki_int_nef_n29/crl"
