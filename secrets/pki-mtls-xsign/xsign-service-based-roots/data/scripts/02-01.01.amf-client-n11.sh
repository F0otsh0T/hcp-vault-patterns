#!/bin/sh

## 

set -e
set -x

# VARS
export VAULT_ADDR_DOCKER='http://192.168.65.2:18200'
export VAULT_ADDR='http://127.0.0.1:18200'

# Set up basic PKI mounts

## AMF N11 Int
vault secrets enable -path=amf_int_n11 pki
vault write amf_int_n11/issuers/import/bundle pem_bundle="$(vault write -field=certificate -format=json smf_root_n11/issuer/default/sign-intermediate  csr="$(vault write -field=csr amf_int_n11/intermediate/generate/internal common_name="carol.amf.5gc.mnc88.mcc888.3gppnetwork.org" max_path_length=0 )" | jq -r '.')"
vault write amf_int_n11/issuer/default issuer_name="amf_int_n11"
# #### AMF N11 Int / CSR
# vault write -format=json amf_int_n11/intermediate/generate/internal \
#     common_name="carol.amf.5gc.mnc88.mcc888.3gppnetwork.org" \
#     max_path_length=0 \
#     | jq > amf_int_n11.csr.json
# jq < amf_int_n11.csr.json
# jq -r '.data.csr' < amf_int_n11.csr.json
# #### AMF N11 Int / Root Sign CSR
# vault write -format=json smf_root_n11/issuer/default/sign-intermediate \
#     csr="$(jq -r '.data.csr' < amf_int_n11.csr.json)" \
#     | jq > amf_int_n11.cert.json
# jq < amf_int_n11.cert.json
# jq -r '.data.certificate' < amf_int_n11.cert.json
# #### AMF N11 Int / Import Root Signed PEM
# vault write -format=json amf_int_n11/issuers/import/bundle \
#     pem_bundle="$(jq -r '.data.certificate' < amf_int_n11.cert.json)" \
#     | jq > amf_int_n11.import.json
# #    pem_bundle="$(jq -r '.data.ca_chain' < amf_int_n11.cert.json)" \
# jq < amf_int_n11.import.json
# #### AMF N11 Int / Update Issuer
# vault write -format=json amf_int_n11/issuer/default \
#     issuer_name="amf_int_n11" \
#     | jq > amf_int_n11.issuer.json
# jq < amf_int_n11.issuer.json
#### AMF N11 Int / Publish CA & CRL Endpoints
vault write amf_int_n11/config/urls \
    issuing_certificates="${VAULT_ADDR_DOCKER}/v1/amf_int_n11/ca,${VAULT_ADDR}/v1/amf_int_n11/ca" \
    crl_distribution_points="${VAULT_ADDR_DOCKER}/v1/amf_int_n11/crl,${VAULT_ADDR}/v1/amf_int_n11/crl"

vault read -format=json amf_int_n11/config/urls > workspace/tmp/amf/amf_int_n11_ca_crl.json
jq < workspace/tmp/amf/amf_int_n11_ca_crl.json
