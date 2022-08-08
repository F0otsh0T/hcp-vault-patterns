#!/bin/sh

## PKI CA Root: SMF

set -e
set -x

# VARS
export VAULT_ADDR_DOCKER='http://192.168.65.2:18200'
export VAULT_ADDR='http://127.0.0.1:18200'

## SMF Root
vault secrets enable -path=pki_root_smf pki
vault secrets tune -max-lease-ttl=8760h pki_root_smf

## SMF Root Certificate
vault write -format=json \
    pki_root_smf/root/generate/internal \
    common_name="smf.5gc.mnc88.mcc888.3gppnetwork.org" \
    max_path_length=2 \
    | tee workspace/tmp/smf/pki_root_smf.cert.json
#    ttl=8760h \
#    organization="5gc.mnc88.mcc888.3gppnetwork.org" \
#jq < workspace/tmp/smf/pki_root_smf.cert.json

#### SMF Root / Publish CA & CRL Endpoints
vault write pki_root_smf/config/urls \
    issuing_certificates="${VAULT_ADDR_DOCKER}/v1/pki_root_smf/ca,${VAULT_ADDR}/v1/pki_root_smf/ca" \
    crl_distribution_points="${VAULT_ADDR_DOCKER}/v1/pki_root_smf/crl,${VAULT_ADDR}/v1/pki_root_smf/crl" \

vault read -format=json pki_root_smf/config/urls > workspace/tmp/smf/pki_root_ca_crl.json
jq < workspace/tmp/smf/pki_root_ca_crl.json

#### Save CA Root Certificate
vault read -field=certificate pki_root_smf/issuer/default > workspace/tmp/smf/root.pem
