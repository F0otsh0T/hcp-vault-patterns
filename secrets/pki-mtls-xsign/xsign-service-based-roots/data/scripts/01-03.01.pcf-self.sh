#!/bin/sh

## 

set -e
set -x

# VARS
export VAULT_ADDR_DOCKER='http://192.168.65.2:18200'
export VAULT_ADDR='http://127.0.0.1:18200'

# Set up basic PKI mounts

## PCF Root
vault secrets enable -path=pcf_root pki
vault secrets tune -max-lease-ttl=8760h pcf_root

## PCF Root Certificate
vault write -format=json \
    pcf_root/root/generate/internal \
    common_name="pcf.5gc.mnc88.mcc888.3gppnetwork.org" \
    max_path_length=2 \
    | tee workspace/tmp/pcf/pcf_root.cert.json
jq < workspace/tmp/pcf/pcf_root.cert.json
#    organization="5gc.mnc88.mcc888.3gppnetwork.org" \

#### PCF Root / Publish CA & CRL Endpoints
vault write pcf_root/config/urls \
    issuing_certificates="${VAULT_ADDR_DOCKER}/v1/pcf_root/ca,${VAULT_ADDR}/v1/pcf_root/ca" \
    crl_distribution_points="${VAULT_ADDR_DOCKER}/v1/pcf_root/crl,${VAULT_ADDR}/v1/pcf_root/crl"

vault read -format=json pcf_root/config/urls > workspace/tmp/pcf/pcf_root_ca_crl.json
jq < workspace/tmp/pcf/pcf_root_ca_crl.json

#### Save CA Root Certificate
vault read -field=certificate pcf_root/issuer/default > workspace/tmp/pcf/pcf_root.pem

## PCF Int
vault secrets enable -path=pcf_int pki
vault write pcf_int/issuers/import/bundle pem_bundle="$(vault write -field=certificate -format=json pcf_root/issuer/default/sign-intermediate  csr="$(vault write -field=csr pcf_int/intermediate/generate/internal common_name="bob.pcf.5gc.mnc88.mcc888.3gppnetwork.org" max_path_length=0 )" | jq -r '.')"
vault write pcf_int/issuer/default issuer_name="pcf_int"
# #### PCF Int / CSR
# vault write -format=json pcf_int/intermediate/generate/internal \
#     common_name="bob.pcf.5gc.mnc88.mcc888.3gppnetwork.org" \
#     max_path_length=0 \
#     | jq > pcf_int.csr.json
# jq < pcf_int.csr.json
# jq -r '.data.csr' < pcf_int.csr.json
# #### PCF Int / Root Sign CSR
# vault write -format=json pcf_root/issuer/default/sign-intermediate \
#     csr="$(jq -r '.data.csr' < pcf_int.csr.json)" \
#     | jq > pcf_int.cert.json
# jq < pcf_int.cert.json
# jq -r '.data.certificate' < pcf_int.cert.json
# #### PCF Int / Import Root Signed PEM
# vault write -format=json pcf_int/issuers/import/bundle \
#     pem_bundle="$(jq -r '.data.certificate' < pcf_int.cert.json)" \
#     | jq > pcf_int.import.json
# #    pem_bundle="$(jq -r '.data.ca_chain' < pcf_int.cert.json)" \
# jq < pcf_int.import.json
# #### PCF Int / Update Issuer
# vault write -format=json pcf_int/issuer/default \
#     issuer_name="pcf_int" \
#     | jq > pcf_int.issuer.json
# jq < pcf_int.issuer.json
#### PCF Int / Publish CA & CRL Endpoints
vault write pcf_int/config/urls \
    issuing_certificates="${VAULT_ADDR_DOCKER}/v1/pcf_int/ca,${VAULT_ADDR}/v1/pcf_int/ca" \
    crl_distribution_points="${VAULT_ADDR_DOCKER}/v1/pcf_int/crl,${VAULT_ADDR}/v1/pcf_int/crl"

vault read -format=json pcf_int/config/urls > workspace/tmp/pcf/pcf_int_ca_crl.json
jq < workspace/tmp/pcf/pcf_int_ca_crl.json
