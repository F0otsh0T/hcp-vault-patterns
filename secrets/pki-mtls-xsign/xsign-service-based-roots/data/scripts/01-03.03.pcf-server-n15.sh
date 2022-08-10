#!/bin/sh

## 

set -e
set -x

# VARS
export VAULT_ADDR_DOCKER='http://192.168.65.2:18200'
export VAULT_ADDR='http://127.0.0.1:18200'

# Set up basic PKI mounts

## PCF N15 Root
vault secrets enable -path=pcf_root_n15 pki
vault secrets tune -max-lease-ttl=8760h pcf_root_n15

## PCF N15 Root Certificate
vault write -format=json \
    pcf_root_n15/root/generate/internal \
    common_name="pcf.5gc.mnc88.mcc888.3gppnetwork.org" \
    max_path_length=2 \
    | tee workspace/tmp/pcf/pcf_root_n15.cert.json
jq < workspace/tmp/pcf/pcf_root_n15.cert.json
#    organization="5gc.mnc88.mcc888.3gppnetwork.org" \

#### PCF N15 Root / Publish CA & CRL Endpoints
vault write pcf_root_n15/config/urls \
    issuing_certificates="${VAULT_ADDR_DOCKER}/v1/pcf_root_n15/ca,${VAULT_ADDR}/v1/pcf_root_n15/ca" \
    crl_distribution_points="${VAULT_ADDR_DOCKER}/v1/pcf_root_n15/crl,${VAULT_ADDR}/v1/pcf_root_n15/crl"

vault read -format=json pcf_root_n15/config/urls > workspace/tmp/pcf/pcf_root_n15_ca_crl.json
jq < workspace/tmp/pcf/pcf_root_n15_ca_crl.json

#### Save CA Root Certificate
vault read -field=certificate pcf_root_n15/issuer/default > workspace/tmp/pcf/pcf_root_n15.pem

## PCF N15 Int
vault secrets enable -path=pcf_int_n15 pki
vault write pcf_int_n15/issuers/import/bundle pem_bundle="$(vault write -field=certificate -format=json pcf_root_n15/issuer/default/sign-intermediate  csr="$(vault write -field=csr pcf_int_n15/intermediate/generate/internal common_name="bob.pcf.5gc.mnc88.mcc888.3gppnetwork.org" max_path_length=0 )" | jq -r '.')"
vault write pcf_int_n15/issuer/default issuer_name="pcf_int_n15"
# #### PCF N15 Int / CSR
# vault write -format=json pcf_int_n15/intermediate/generate/internal \
#     common_name="bob.pcf.5gc.mnc88.mcc888.3gppnetwork.org" \
#     max_path_length=0 \
#     | jq > pcf_int_n15.csr.json
# jq < pcf_int_n15.csr.json
# jq -r '.data.csr' < pcf_int_n15.csr.json
# #### PCF N15 Int / Root Sign CSR
# vault write -format=json pcf_root_n15/issuer/default/sign-intermediate \
#     csr="$(jq -r '.data.csr' < pcf_int_n15.csr.json)" \
#     | jq > pcf_int_n15.cert.json
# jq < pcf_int_n15.cert.json
# jq -r '.data.certificate' < pcf_int_n15.cert.json
# #### PCF N15 Int / Import Root Signed PEM
# vault write -format=json pcf_int_n15/issuers/import/bundle \
#     pem_bundle="$(jq -r '.data.certificate' < pcf_int_n15.cert.json)" \
#     | jq > pcf_int_n15.import.json
# #    pem_bundle="$(jq -r '.data.ca_chain' < pcf_int_n15.cert.json)" \
# jq < pcf_int_n15.import.json
# #### PCF N15 Int / Update Issuer
# vault write -format=json pcf_int_n15/issuer/default \
#     issuer_name="pcf_int_n15" \
#     | jq > pcf_int_n15.issuer.json
# jq < pcf_int_n15.issuer.json
#### PCF N15 Int / Publish CA & CRL Endpoints
vault write pcf_int_n15/config/urls \
    issuing_certificates="${VAULT_ADDR_DOCKER}/v1/pcf_int_n15/ca,${VAULT_ADDR}/v1/pcf_int_n15/ca" \
    crl_distribution_points="${VAULT_ADDR_DOCKER}/v1/pcf_int_n15/crl,${VAULT_ADDR}/v1/pcf_int_n15/crl"

vault read -format=json pcf_int_n15/config/urls > workspace/tmp/pcf/pcf_int_n15_ca_crl.json
jq < workspace/tmp/pcf/pcf_int_n15_ca_crl.json
