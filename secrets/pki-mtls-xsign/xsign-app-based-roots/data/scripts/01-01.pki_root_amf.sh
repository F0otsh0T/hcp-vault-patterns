#!/bin/sh

## PKI CA Root: AMF

set -e
set -x

# VARS
export VAULT_ADDR_DOCKER='http://192.168.65.2:18200'
export VAULT_ADDR='http://127.0.0.1:18200'

## AMF Root
vault secrets enable -path=pki_root_amf pki
vault secrets tune -max-lease-ttl=8760h pki_root_amf

## AMF Root Certificate
vault write -format=json \
    pki_root_amf/root/generate/internal \
    common_name="amf.5gc.mnc88.mcc888.3gppnetwork.org" \
    max_path_length=2 \
    | tee workspace/tmp/amf/pki_root_amf.cert.json
#    ttl=8760h \
#    organization="5gc.mnc88.mcc888.3gppnetwork.org" \
#jq < workspace/tmp/amf/pki_root_amf.cert.json

#### AMF Root / Publish CA & CRL Endpoints
vault write pki_root_amf/config/urls \
    issuing_certificates="${VAULT_ADDR_DOCKER}/v1/pki_root_amf/ca,${VAULT_ADDR}/v1/pki_root_amf/ca" \
    crl_distribution_points="${VAULT_ADDR_DOCKER}/v1/pki_root_amf/crl,${VAULT_ADDR}/v1/pki_root_amf/crl" \

vault read -format=json pki_root_amf/config/urls > workspace/tmp/amf/pki_root_ca_crl.json
jq < workspace/tmp/amf/pki_root_ca_crl.json

#### Save CA Root Certificate
vault read -field=certificate pki_root_amf/issuer/default > workspace/tmp/amf/root.pem
