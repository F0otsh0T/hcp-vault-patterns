#!/bin/sh

## 

set -e
set -x

# VARS
export VAULT_ADDR_DOCKER='http://192.168.65.2:18200'
export VAULT_ADDR='http://127.0.0.1:18200'

## SMF Int
vault secrets enable -path=pki_int_smf pki
vault secrets tune -max-lease-ttl=2160h pki_int_smf

## SMF CSR, Sign, Import
vault write pki_int_smf/issuers/import/bundle pem_bundle="$(vault write -field=certificate -format=json pki_root_smf/issuer/default/sign-intermediate  csr="$(vault write -field=csr pki_int_smf/intermediate/generate/internal common_name="alice.smf.5gc.mnc88.mcc888.3gppnetwork.org" max_path_length=0 )" | jq -r '.')"
vault write pki_int_smf/issuer/default issuer_name="pki_int_smf"

##### SMF Int / CSR
#vault write -format=json pki_int_smf/intermediate/generate/internal \
#    common_name="alice.smf.5gc.mnc88.mcc888.3gppnetwork.org" \
#    max_path_length=0 \
#    | tee workspace/tmp/smf/pki_int_smf.csr.json
##    ttl=2160h \
##    organization="5gc.mnc88.mcc888.3gppnetwork.org" \
#jq < workspace/tmp/smf/pki_int_smf.csr.json
#jq -r '.data.csr' < workspace/tmp/smf/pki_int_smf.csr.json > workspace/tmp/smf/pki_int_smf.csr

##### SMF Int / Root Sign CSR
#vault write -format=json pki_root_smf/issuer/default/sign-intermediate \
#    csr="$(jq -r '.data.csr' < workspace/tmp/smf/pki_int_smf.csr.json)" \
#    | tee workspace/tmp/smf/pki_int_smf.cert.json
#jq < workspace/tmp/smf/pki_int_smf.cert.json
#jq -r '.data.certificate' < workspace/tmp/smf/pki_int_smf.cert.json > workspace/tmp/smf/pki_int_smf.pem

##### SMF Int / Import Root Signed PEM
#vault write -format=json pki_int_smf/issuers/import/bundle \
#    pem_bundle="$(jq -r '.data.certificate' < workspace/tmp/smf/pki_int_smf.cert.json)" \
#    | tee workspace/tmp/smf/pki_int_smf.import.json
##    pem_bundle="$(jq -r '.data.ca_chain' < workspace/tmp/smf/pki_int_smf.cert.json)" \
#jq < workspace/tmp/smf/pki_int_smf.import.json

##### SMF Int / Update Issuer
#vault write -format=json pki_int_smf/issuer/default \
#    issuer_name="pki_int_smf" \
#    | tee workspace/tmp/smf/pki_int_smf.issuer.json
#jq < workspace/tmp/smf/pki_int_smf.issuer.json

#### SMF Int / Publish CA & CRL Endpoints
vault write pki_int_smf/config/urls \
    issuing_certificates="${VAULT_ADDR_DOCKER}/v1/pki_int_smf/ca,${VAULT_ADDR}/v1/pki_int_smf/ca" \
    crl_distribution_points="${VAULT_ADDR_DOCKER}/v1/pki_int_smf/crl,${VAULT_ADDR}/v1/pki_int_smf/crl"
