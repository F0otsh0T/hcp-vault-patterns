#!/bin/sh

## 

set -e
set -x

# VARS
export VAULT_ADDR_DOCKER='http://192.168.65.2:18200'
export VAULT_ADDR='http://127.0.0.1:18200'

# Set up basic PKI mounts

## AMF Root
vault secrets enable -path=amf_root pki
vault secrets tune -max-lease-ttl=8760h amf_root

## AMF Root Certificate
vault write -format=json \
    amf_root/root/generate/internal \
    common_name="amf.5gc.mnc88.mcc888.3gppnetwork.org" \
    max_path_length=2 \
    | tee workspace/tmp/amf/amf_root.cert.json
jq < workspace/tmp/amf/amf_root.cert.json
#    organization="5gc.mnc88.mcc888.3gppnetwork.org" \

#### AMF Root / Publish CA & CRL Endpoints
vault write amf_root/config/urls \
    issuing_certificates="${VAULT_ADDR_DOCKER}/v1/amf_root/ca,${VAULT_ADDR}/v1/amf_root/ca" \
    crl_distribution_points="${VAULT_ADDR_DOCKER}/v1/amf_root/crl,${VAULT_ADDR}/v1/amf_root/crl"

vault read -format=json amf_root/config/urls > workspace/tmp/amf/amf_root_ca_crl.json
jq < workspace/tmp/amf/amf_root_ca_crl.json

#### Save CA Root Certificate
vault read -field=certificate amf_root/issuer/default > workspace/tmp/amf/amf_root.pem

## AMF Int
vault secrets enable -path=amf_int pki
vault write amf_int/issuers/import/bundle pem_bundle="$(vault write -field=certificate -format=json amf_root/issuer/default/sign-intermediate  csr="$(vault write -field=csr amf_int/intermediate/generate/internal common_name="carol.amf.5gc.mnc88.mcc888.3gppnetwork.org" max_path_length=0 )" | jq -r '.')"
vault write amf_int/issuer/default issuer_name="amf_int"
# #### AMF Int / CSR
# vault write -format=json amf_int/intermediate/generate/internal \
#     common_name="carol.amf.5gc.mnc88.mcc888.3gppnetwork.org" \
#     max_path_length=0 \
#     | jq > amf_int.csr.json
# jq < amf_int.csr.json
# jq -r '.data.csr' < amf_int.csr.json
# #### AMF Int / Root Sign CSR
# vault write -format=json amf_root/issuer/default/sign-intermediate \
#     csr="$(jq -r '.data.csr' < amf_int.csr.json)" \
#     | jq > amf_int.cert.json
# jq < amf_int.cert.json
# jq -r '.data.certificate' < amf_int.cert.json
# #### AMF Int / Import Root Signed PEM
# vault write -format=json amf_int/issuers/import/bundle \
#     pem_bundle="$(jq -r '.data.certificate' < amf_int.cert.json)" \
#     | jq > amf_int.import.json
# #    pem_bundle="$(jq -r '.data.ca_chain' < amf_int.cert.json)" \
# jq < amf_int.import.json
# #### AMF Int / Update Issuer
# vault write -format=json amf_int/issuer/default \
#     issuer_name="amf_int" \
#     | jq > amf_int.issuer.json
# jq < amf_int.issuer.json
#### AMF Int / Publish CA & CRL Endpoints
vault write amf_int/config/urls \
    issuing_certificates="${VAULT_ADDR_DOCKER}/v1/amf_int/ca,${VAULT_ADDR}/v1/amf_int/ca" \
    crl_distribution_points="${VAULT_ADDR_DOCKER}/v1/amf_int/crl,${VAULT_ADDR}/v1/amf_int/crl"

vault read -format=json amf_int/config/urls > workspace/tmp/amf/amf_int_ca_crl.json
jq < workspace/tmp/amf/amf_int_ca_crl.json
