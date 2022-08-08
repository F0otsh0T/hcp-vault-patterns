#!/bin/sh

## PKI CA Root: PCF

set -e
set -x

# VARS
export VAULT_ADDR_DOCKER='http://192.168.65.2:18200'
export VAULT_ADDR='http://127.0.0.1:18200'

## PCF Root
vault secrets enable -path=pki_root_pcf pki
vault secrets tune -max-lease-ttl=8760h pki_root_pcf

## PCF Root Certificate
vault write -format=json \
    pki_root_pcf/root/generate/internal \
    common_name="pcf.5gc.mnc88.mcc888.3gppnetwork.org" \
    max_path_length=2 \
    | tee workspace/tmp/pcf/pki_root_pcf.cert.json
#    ttl=8760h
#    organization="5gc.mnc88.mcc888.3gppnetwork.org" \
#jq < workspace/tmp/pcf/pki_root_pcf.cert.json

#### PCF Root / Publish CA & CRL Endpoints
vault write pki_root_pcf/config/urls \
    issuing_certificates="${VAULT_ADDR_DOCKER}/v1/pki_root_pcf/ca,${VAULT_ADDR}/v1/pki_root_pcf/ca" \
    crl_distribution_points="${VAULT_ADDR_DOCKER}/v1/pki_root_pcf/crl,${VAULT_ADDR}/v1/pki_root_pcf/crl" \

vault read -format=json pki_root_pcf/config/urls > workspace/tmp/pcf/pki_root_ca_crl.json
jq < workspace/tmp/pcf/pki_root_ca_crl.json

#### Save CA Root Certificate
vault read -field=certificate pki_root_pcf/issuer/default > workspace/tmp/pcf/root.pem
