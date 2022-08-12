#!/bin/sh

## 

set -e
set -x

# VARS
export VAULT_ADDR_DOCKER='http://192.168.65.2:18200'
export VAULT_ADDR='http://127.0.0.1:18200'

# Set up basic PKI mounts

## SMF N7 Int
vault secrets enable -path=smf_int_n7 pki
vault write smf_int_n7/issuers/import/bundle pem_bundle="$(vault write -field=certificate -format=json pcf_root_n7/issuer/default/sign-intermediate  csr="$(vault write -field=csr smf_int_n7/intermediate/generate/internal common_name="alice.smf.5gc.mnc88.mcc888.3gppnetwork.org" max_path_length=0 )" | jq -r '.')"
vault write smf_int_n7/issuer/default issuer_name="smf_int_n7"
# #### SMF N7 Int / CSR
# vault write -format=json smf_int_n7/intermediate/generate/internal \
#     common_name="alice.smf.5gc.mnc88.mcc888.3gppnetwork.org" \
#     max_path_length=0 \
#     | jq > smf_int_n7.csr.json
# jq < smf_int_n7.csr.json
# jq -r '.data.csr' < smf_int_n7.csr.json
# #### SMF N7 Int / Root Sign CSR
# vault write -format=json pcf_root_n7/issuer/default/sign-intermediate \
#     csr="$(jq -r '.data.csr' < smf_int_n7.csr.json)" \
#     | jq > smf_int_n7.cert.json
# jq < smf_int_n7.cert.json
# jq -r '.data.certificate' < smf_int_n7.cert.json
# #### SMF N7 Int / Import Root Signed PEM
# vault write -format=json smf_int_n7/issuers/import/bundle \
#     pem_bundle="$(jq -r '.data.certificate' < smf_int_n7.cert.json)" \
#     | jq > smf_int_n7.import.json
# #    pem_bundle="$(jq -r '.data.ca_chain' < smf_int_n7.cert.json)" \
# jq < smf_int_n7.import.json
# #### SMF N7 Int / Update Issuer
# vault write -format=json smf_int_n7/issuer/default \
#     issuer_name="smf_int_n7" \
#     | jq > smf_int_n7.issuer.json
# jq < smf_int_n7.issuer.json
#### SMF N7 Int / Publish CA & CRL Endpoints
vault write smf_int_n7/config/urls \
    issuing_certificates="${VAULT_ADDR_DOCKER}/v1/smf_int_n7/ca,${VAULT_ADDR}/v1/smf_int_n7/ca" \
    crl_distribution_points="${VAULT_ADDR_DOCKER}/v1/smf_int_n7/crl,${VAULT_ADDR}/v1/smf_int_n7/crl"

vault read -format=json smf_int_n7/config/urls > workspace/tmp/smf/smf_int_n7_ca_crl.json
jq < workspace/tmp/smf/smf_int_n7_ca_crl.json
