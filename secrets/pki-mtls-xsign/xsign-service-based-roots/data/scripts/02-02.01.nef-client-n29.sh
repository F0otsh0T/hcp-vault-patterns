#!/bin/sh

## 

set -e
set -x

# VARS
export VAULT_ADDR_DOCKER='http://192.168.65.2:18200'
export VAULT_ADDR='http://127.0.0.1:18200'

# Set up basic PKI mounts

## NEF N29 Int
vault secrets enable -path=nef_int_n29 pki
vault write nef_int_n29/issuers/import/bundle pem_bundle="$(vault write -field=certificate -format=json smf_root_n29/issuer/default/sign-intermediate  csr="$(vault write -field=csr nef_int_n29/intermediate/generate/internal common_name="charlie.nef.5gc.mnc88.mcc888.3gppnetwork.org" max_path_length=0 )" | jq -r '.')"
vault write nef_int_n29/issuer/default issuer_name="nef_int_n29"
# #### NEF N29 Int / CSR
# vault write -format=json nef_int_n29/intermediate/generate/internal \
#     common_name="charlie.nef.5gc.mnc88.mcc888.3gppnetwork.org" \
#     max_path_length=0 \
#     | jq > nef_int_n29.csr.json
# jq < nef_int_n29.csr.json
# jq -r '.data.csr' < nef_int_n29.csr.json
# #### NEF N29 Int / Root Sign CSR
# vault write -format=json smf_root_n29/issuer/default/sign-intermediate \
#     csr="$(jq -r '.data.csr' < nef_int_n29.csr.json)" \
#     | jq > nef_int_n29.cert.json
# jq < nef_int_n29.cert.json
# jq -r '.data.certificate' < nef_int_n29.cert.json
# #### NEF N29 Int / Import Root Signed PEM
# vault write -format=json nef_int_n29/issuers/import/bundle \
#     pem_bundle="$(jq -r '.data.certificate' < nef_int_n29.cert.json)" \
#     | jq > nef_int_n29.import.json
# #    pem_bundle="$(jq -r '.data.ca_chain' < nef_int_n29.cert.json)" \
# jq < nef_int_n29.import.json
# #### NEF N29 Int / Update Issuer
# vault write -format=json nef_int_n29/issuer/default \
#     issuer_name="nef_int_n29" \
#     | jq > nef_int_n29.issuer.json
# jq < nef_int_n29.issuer.json
#### NEF N29 Int / Publish CA & CRL Endpoints
vault write nef_int_n29/config/urls \
    issuing_certificates="${VAULT_ADDR_DOCKER}/v1/nef_int_n29/ca,${VAULT_ADDR}/v1/nef_int_n29/ca" \
    crl_distribution_points="${VAULT_ADDR_DOCKER}/v1/nef_int_n29/crl,${VAULT_ADDR}/v1/nef_int_n29/crl"

vault read -format=json nef_int_n29/config/urls > workspace/tmp/nef/nef_int_n29_ca_crl.json
jq < workspace/tmp/nef/nef_int_n29_ca_crl.json
