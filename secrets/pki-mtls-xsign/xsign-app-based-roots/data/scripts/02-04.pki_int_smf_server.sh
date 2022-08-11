#!/bin/sh

## 

set -e
set -x

# VARS
export VAULT_ADDR_DOCKER='http://192.168.65.2:18200'
export VAULT_ADDR='http://127.0.0.1:18200'

## SMF Int
vault secrets enable -path=pki_int_smf_server pki
vault secrets tune -max-lease-ttl=2160h pki_int_smf_server

## SMF CSR, Sign, Import
vault write pki_int_smf_server/issuers/import/bundle pem_bundle="$(vault write -field=certificate -format=json pki_root_smf/issuer/default/sign-intermediate  csr="$(vault write -field=csr pki_int_smf_server/intermediate/generate/internal common_name="alice.smf.5gc.mnc88.mcc888.3gppnetwork.org" max_path_length=0 )" | jq -r '.')"
vault write pki_int_smf_server/issuer/default issuer_name="pki_int_smf_server"

##### SMF Int / CSR
#vault write -format=json pki_int_smf_server/intermediate/generate/internal \
#    common_name="alice.smf.5gc.mnc88.mcc888.3gppnetwork.org" \
#    max_path_length=0 \
#    | tee workspace/tmp/smf/pki_int_smf_server.csr.json
##    ttl=2160h \
##    organization="5gc.mnc88.mcc888.3gppnetwork.org" \
#jq < workspace/tmp/smf/pki_int_smf_server.csr.json
#jq -r '.data.csr' < workspace/tmp/smf/pki_int_smf_server.csr.json > workspace/tmp/smf/pki_int_smf_server.csr

##### SMF Int / Root Sign CSR
#vault write -format=json pki_root_smf/issuer/default/sign-intermediate \
#    csr="$(jq -r '.data.csr' < workspace/tmp/smf/pki_int_smf_server.csr.json)" \
#    | tee workspace/tmp/smf/pki_int_smf_server.cert.json
#jq < workspace/tmp/smf/pki_int_smf_server.cert.json
#jq -r '.data.certificate' < workspace/tmp/smf/pki_int_smf_server.cert.json > workspace/tmp/smf/pki_int_smf_server.pem

##### SMF Int / Import Root Signed PEM
#vault write -format=json pki_int_smf_server/issuers/import/bundle \
#    pem_bundle="$(jq -r '.data.certificate' < workspace/tmp/smf/pki_int_smf_server.cert.json)" \
#    | tee workspace/tmp/smf/pki_int_smf_server.import.json
##    pem_bundle="$(jq -r '.data.ca_chain' < workspace/tmp/smf/pki_int_smf_server.cert.json)" \
#jq < workspace/tmp/smf/pki_int_smf_server.import.json

##### SMF Int / Update Issuer
#vault write -format=json pki_int_smf_server/issuer/default \
#    issuer_name="pki_int_smf_server" \
#    | tee workspace/tmp/smf/pki_int_smf_server.issuer.json
#jq < workspace/tmp/smf/pki_int_smf_server.issuer.json

#### SMF Int / Publish CA & CRL Endpoints
vault write pki_int_smf_server/config/urls \
    issuing_certificates="${VAULT_ADDR_DOCKER}/v1/pki_int_smf_server/ca,${VAULT_ADDR}/v1/pki_int_smf_server/ca" \
    crl_distribution_points="${VAULT_ADDR_DOCKER}/v1/pki_int_smf_server/crl,${VAULT_ADDR}/v1/pki_int_smf_server/crl"
