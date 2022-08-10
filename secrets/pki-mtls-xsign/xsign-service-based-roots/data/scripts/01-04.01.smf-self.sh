#!/bin/sh

## 

set -e
set -x

# VARS
export VAULT_ADDR_DOCKER='http://192.168.65.2:18200'
export VAULT_ADDR='http://127.0.0.1:18200'

# Set up basic PKI mounts

## SMF Root
vault secrets enable -path=smf_root pki
vault secrets tune -max-lease-ttl=8760h smf_root

## SMF Root Certificate
vault write -format=json \
    smf_root/root/generate/internal \
    common_name="smf.5gc.mnc88.mcc888.3gppnetwork.org" \
    max_path_length=2 \
    | tee workspace/tmp/smf/smf_root.cert.json
jq < workspace/tmp/smf/smf_root.cert.json
#    organization="5gc.mnc88.mcc888.3gppnetwork.org" \

#### SMF Root / Publish CA & CRL Endpoints
vault write smf_root/config/urls \
    issuing_certificates="${VAULT_ADDR_DOCKER}/v1/smf_root/ca,${VAULT_ADDR}/v1/smf_root/ca" \
    crl_distribution_points="${VAULT_ADDR_DOCKER}/v1/smf_root/crl,${VAULT_ADDR}/v1/smf_root/crl"

vault read -format=json smf_root/config/urls > workspace/tmp/smf/smf_root_ca_crl.json
jq < workspace/tmp/smf/smf_root_ca_crl.json

#### Save CA Root Certificate
vault read -field=certificate smf_root/issuer/default > workspace/tmp/smf/smf_root.pem

## SMF Int
vault secrets enable -path=smf_int pki
vault write smf_int/issuers/import/bundle pem_bundle="$(vault write -field=certificate -format=json smf_root/issuer/default/sign-intermediate  csr="$(vault write -field=csr smf_int/intermediate/generate/internal common_name="alice.smf.5gc.mnc88.mcc888.3gppnetwork.org" max_path_length=0 )" | jq -r '.')"
vault write smf_int/issuer/default issuer_name="smf_int"
# #### SMF Int / CSR
# vault write -format=json smf_int/intermediate/generate/internal \
#     common_name="alice.smf.5gc.mnc88.mcc888.3gppnetwork.org" \
#     max_path_length=0 \
#     | jq > smf_int.csr.json
# jq < smf_int.csr.json
# jq -r '.data.csr' < smf_int.csr.json
# #### SMF Int / Root Sign CSR
# vault write -format=json smf_root/issuer/default/sign-intermediate \
#     csr="$(jq -r '.data.csr' < smf_int.csr.json)" \
#     | jq > smf_int.cert.json
# jq < smf_int.cert.json
# jq -r '.data.certificate' < smf_int.cert.json
# #### SMF Int / Import Root Signed PEM
# vault write -format=json smf_int/issuers/import/bundle \
#     pem_bundle="$(jq -r '.data.certificate' < smf_int.cert.json)" \
#     | jq > smf_int.import.json
# #    pem_bundle="$(jq -r '.data.ca_chain' < smf_int.cert.json)" \
# jq < smf_int.import.json
# #### SMF Int / Update Issuer
# vault write -format=json smf_int/issuer/default \
#     issuer_name="smf_int" \
#     | jq > smf_int.issuer.json
# jq < smf_int.issuer.json
#### SMF Int / Publish CA & CRL Endpoints
vault write smf_int/config/urls \
    issuing_certificates="${VAULT_ADDR_DOCKER}/v1/smf_int/ca,${VAULT_ADDR}/v1/smf_int/ca" \
    crl_distribution_points="${VAULT_ADDR_DOCKER}/v1/smf_int/crl,${VAULT_ADDR}/v1/smf_int/crl"

vault read -format=json smf_int/config/urls > workspace/tmp/smf/smf_int_ca_crl.json
jq < workspace/tmp/smf/smf_int_ca_crl.json
