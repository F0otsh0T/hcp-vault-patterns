#!/bin/sh

## 

set -e
set -x

# VARS
export VAULT_ADDR_DOCKER='http://192.168.65.2:18200'
export VAULT_ADDR='http://127.0.0.1:18200'

# Set up basic PKI mounts

## NEF Root
vault secrets enable -path=nef_root pki
vault secrets tune -max-lease-ttl=8760h nef_root

## NEF Root Certificate
vault write -format=json \
    nef_root/root/generate/internal \
    common_name="nef.5gc.mnc88.mcc888.3gppnetwork.org" \
    max_path_length=2 \
    | tee workspace/tmp/nef/nef_root.cert.json
jq < workspace/tmp/nef/nef_root.cert.json
#    organization="5gc.mnc88.mcc888.3gppnetwork.org" \

#### NEF Root / Publish CA & CRL Endpoints
vault write nef_root/config/urls \
    issuing_certificates="${VAULT_ADDR_DOCKER}/v1/nef_root/ca,${VAULT_ADDR}/v1/nef_root/ca" \
    crl_distribution_points="${VAULT_ADDR_DOCKER}/v1/nef_root/crl,${VAULT_ADDR}/v1/nef_root/crl"

vault read -format=json nef_root/config/urls > workspace/tmp/nef/nef_root_ca_crl.json
jq < workspace/tmp/nef/nef_root_ca_crl.json

#### Save CA Root Certificate
vault read -field=certificate nef_root/issuer/default > workspace/tmp/nef/nef_root.pem

## NEF Int
vault secrets enable -path=nef_int pki
vault write nef_int/issuers/import/bundle pem_bundle="$(vault write -field=certificate -format=json nef_root/issuer/default/sign-intermediate  csr="$(vault write -field=csr nef_int/intermediate/generate/internal common_name="charlie.nef.5gc.mnc88.mcc888.3gppnetwork.org" max_path_length=0 )" | jq -r '.')"
vault write nef_int/issuer/default issuer_name="nef_int"
# #### NEF Int / CSR
# vault write -format=json nef_int/intermediate/generate/internal \
#     common_name="charlie.nef.5gc.mnc88.mcc888.3gppnetwork.org" \
#     max_path_length=0 \
#     | jq > nef_int.csr.json
# jq < nef_int.csr.json
# jq -r '.data.csr' < nef_int.csr.json
# #### NEF Int / Root Sign CSR
# vault write -format=json nef_root/issuer/default/sign-intermediate \
#     csr="$(jq -r '.data.csr' < nef_int.csr.json)" \
#     | jq > nef_int.cert.json
# jq < nef_int.cert.json
# jq -r '.data.certificate' < nef_int.cert.json
# #### NEF Int / Import Root Signed PEM
# vault write -format=json nef_int/issuers/import/bundle \
#     pem_bundle="$(jq -r '.data.certificate' < nef_int.cert.json)" \
#     | jq > nef_int.import.json
# #    pem_bundle="$(jq -r '.data.ca_chain' < nef_int.cert.json)" \
# jq < nef_int.import.json
# #### NEF Int / Update Issuer
# vault write -format=json nef_int/issuer/default \
#     issuer_name="nef_int" \
#     | jq > nef_int.issuer.json
# jq < nef_int.issuer.json
#### NEF Int / Publish CA & CRL Endpoints
vault write nef_int/config/urls \
    issuing_certificates="${VAULT_ADDR_DOCKER}/v1/nef_int/ca,${VAULT_ADDR}/v1/nef_int/ca" \
    crl_distribution_points="${VAULT_ADDR_DOCKER}/v1/nef_int/crl,${VAULT_ADDR}/v1/nef_int/crl"

vault read -format=json nef_int/config/urls > workspace/tmp/nef/nef_int_ca_crl.json
jq < workspace/tmp/nef/nef_int_ca_crl.json
