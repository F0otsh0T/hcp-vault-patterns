#!/bin/sh

## PKI CA Root: NEF

set -e
set -x

# VARS
export VAULT_ADDR_DOCKER='http://192.168.65.2:18200'
export VAULT_ADDR='http://127.0.0.1:18200'

## NEF Root
vault secrets enable -path=pki_root_nef pki
vault secrets tune -max-lease-ttl=8760h pki_root_nef

## NEF Root Certificate
vault write -format=json \
    pki_root_nef/root/generate/internal \
    common_name="nef.5gc.mnc88.mcc888.3gppnetwork.org" \
    max_path_length=2 \
    | tee workspace/tmp/nef/pki_root_nef.cert.json
#    ttl=8760h \
#    organization="5gc.mnc88.mcc888.3gppnetwork.org" \
#jq < workspace/tmp/nef/pki_root_nef.cert.json

#### NEF Root / Publish CA & CRL Endpoints
vault write pki_root_nef/config/urls \
    issuing_certificates="${VAULT_ADDR_DOCKER}/v1/pki_root_nef/ca,${VAULT_ADDR}/v1/pki_root_nef/ca" \
    crl_distribution_points="${VAULT_ADDR_DOCKER}/v1/pki_root_nef/crl,${VAULT_ADDR}/v1/pki_root_nef/crl" \

vault read -format=json pki_root_nef/config/urls > workspace/tmp/nef/pki_root_ca_crl.json
jq < workspace/tmp/nef/pki_root_ca_crl.json

#### Save CA Root Certificate
vault read -field=certificate pki_root_nef/issuer/default > workspace/tmp/nef/root.pem
