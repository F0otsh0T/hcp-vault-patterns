#!/bin/sh

## 

set -e
set -x

# VARS
export VAULT_ADDR_DOCKER='http://192.168.65.2:18200'
export VAULT_ADDR='http://127.0.0.1:18200'

# Set up basic PKI mounts

## SMF N11 Root
vault secrets enable -path=smf_root_n11 pki
vault secrets tune -max-lease-ttl=8760h smf_root_n11

## SMF N11 Root Certificate
vault write -format=json \
    smf_root_n11/root/generate/internal \
    common_name="smf.5gc.mnc88.mcc888.3gppnetwork.org" \
    max_path_length=2 \
    | tee workspace/tmp/smf/smf_root_n11.cert.json
jq < workspace/tmp/smf/smf_root_n11.cert.json
#    organization="5gc.mnc88.mcc888.3gppnetwork.org" \

#### SMF N11 Root / Publish CA & CRL Endpoints
vault write smf_root_n11/config/urls \
    issuing_certificates="${VAULT_ADDR_DOCKER}/v1/smf_root_n11/ca,${VAULT_ADDR}/v1/smf_root_n11/ca" \
    crl_distribution_points="${VAULT_ADDR_DOCKER}/v1/smf_root_n11/crl,${VAULT_ADDR}/v1/smf_root_n11/crl"

vault read -format=json smf_root_n11/config/urls > workspace/tmp/smf/smf_root_n11_ca_crl.json
jq < workspace/tmp/smf/smf_root_n11_ca_crl.json

#### Save CA Root Certificate
vault read -field=certificate smf_root_n11/issuer/default > workspace/tmp/smf/smf_root_n11.pem

## SMF N11 Int
vault secrets enable -path=smf_int_n11 pki
vault write smf_int_n11/issuers/import/bundle pem_bundle="$(vault write -field=certificate -format=json smf_root_n11/issuer/default/sign-intermediate  csr="$(vault write -field=csr smf_int_n11/intermediate/generate/internal common_name="alice.smf.5gc.mnc88.mcc888.3gppnetwork.org" max_path_length=0 )" | jq -r '.')"
vault write smf_int_n11/issuer/default issuer_name="smf_int_n11"
# #### SMF N11 Int / CSR
# vault write -format=json smf_int_n11/intermediate/generate/internal \
#     common_name="alice.smf.5gc.mnc88.mcc888.3gppnetwork.org" \
#     max_path_length=0 \
#     | jq > smf_int_n11.csr.json
# jq < smf_int_n11.csr.json
# jq -r '.data.csr' < smf_int_n11.csr.json
# #### SMF N11 Int / Root Sign CSR
# vault write -format=json smf_root_n11/issuer/default/sign-intermediate \
#     csr="$(jq -r '.data.csr' < smf_int_n11.csr.json)" \
#     | jq > smf_int_n11.cert.json
# jq < smf_int_n11.cert.json
# jq -r '.data.certificate' < smf_int_n11.cert.json
# #### SMF N11 Int / Import Root Signed PEM
# vault write -format=json smf_int_n11/issuers/import/bundle \
#     pem_bundle="$(jq -r '.data.certificate' < smf_int_n11.cert.json)" \
#     | jq > smf_int_n11.import.json
# #    pem_bundle="$(jq -r '.data.ca_chain' < smf_int_n11.cert.json)" \
# jq < smf_int_n11.import.json
# #### SMF N11 Int / Update Issuer
# vault write -format=json smf_int_n11/issuer/default \
#     issuer_name="smf_int_n11" \
#     | jq > smf_int_n11.issuer.json
# jq < smf_int_n11.issuer.json
#### SMF N11 Int / Publish CA & CRL Endpoints
vault write smf_int_n11/config/urls \
    issuing_certificates="${VAULT_ADDR_DOCKER}/v1/smf_int_n11/ca,${VAULT_ADDR}/v1/smf_int_n11/ca" \
    crl_distribution_points="${VAULT_ADDR_DOCKER}/v1/smf_int_n11/crl,${VAULT_ADDR}/v1/smf_int_n11/crl"

vault read -format=json smf_int_n11/config/urls > workspace/tmp/smf/smf_int_n11_ca_crl.json
jq < workspace/tmp/smf/smf_int_n11_ca_crl.json
