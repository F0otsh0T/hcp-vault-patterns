#!/bin/sh

## 

set -e
set -x

# VARS
export VAULT_ADDR_DOCKER='http://192.168.65.2:18200'
export VAULT_ADDR='http://127.0.0.1:18200'

## PCF Int
vault secrets enable -path=pki_int_pcf pki
vault secrets tune -max-lease-ttl=2160h pki_int_pcf

## PCF CSR, Sign, Import
vault write pki_int_pcf/issuers/import/bundle pem_bundle="$(vault write -field=certificate -format=json pki_root_pcf/issuer/default/sign-intermediate  csr="$(vault write -field=csr pki_int_pcf/intermediate/generate/internal common_name="bob.pcf.5gc.mnc88.mcc888.3gppnetwork.org" max_path_length=0 )" | jq -r '.')"
vault write pki_int_pcf/issuer/default issuer_name="pki_int_pcf"

##### PCF Int / CSR
#vault write -format=json pki_int_pcf/intermediate/generate/internal \
#    common_name="bob.pcf.5gc.mnc88.mcc888.3gppnetwork.org" \
#    max_path_length=0 \
#    | tee workspace/tmp/pcf/pki_int_pcf.csr.json
##    ttl=2160h \
##    organization="5gc.mnc88.mcc888.3gppnetwork.org" \
#jq < workspace/tmp/pcf/pki_int_pcf.csr.json
#jq -r '.data.csr' < workspace/tmp/pcf/pki_int_pcf.csr.json > workspace/tmp/pcf/pki_int_pcf.csr

##### PCF Int / Root Sign CSR
#vault write -format=json pki_root_pcf/issuer/default/sign-intermediate \
#    csr="$(jq -r '.data.csr' < workspace/tmp/pcf/pki_int_pcf.csr.json)" \
#    | tee workspace/tmp/pcf/pki_int_pcf.cert.json
#jq < workspace/tmp/pcf/pki_int_pcf.cert.json
#jq -r '.data.certificate' < workspace/tmp/pcf/pki_int_pcf.cert.json > workspace/tmp/pcf/pki_int_pcf.pem

##### PCF Int / Import Root Signed PEM
#vault write -format=json pki_int_pcf/issuers/import/bundle \
#    pem_bundle="$(jq -r '.data.certificate' < workspace/tmp/pcf/pki_int_pcf.cert.json)" \
#    | tee workspace/tmp/pcf/pki_int_pcf.import.json
##    pem_bundle="$(jq -r '.data.ca_chain' < workspace/tmp/pcf/pki_int_pcf.cert.json)" \
#jq < workspace/tmp/pcf/pki_int_pcf.import.json

##### PCF Int / Update Issuer
#vault write -format=json pki_int_pcf/issuer/default \
#    issuer_name="pki_int_pcf" \
#    | tee workspace/tmp/pcf/pki_int_pcf.issuer.json
#jq < workspace/tmp/pcf/pki_int_pcf.issuer.json

#### PCF Int / Publish CA & CRL Endpoints
vault write pki_int_pcf/config/urls \
    issuing_certificates="${VAULT_ADDR_DOCKER}/v1/pki_int_pcf/ca,${VAULT_ADDR}/v1/pki_int_pcf/ca" \
    crl_distribution_points="${VAULT_ADDR_DOCKER}/v1/pki_int_pcf/crl,${VAULT_ADDR}/v1/pki_int_pcf/crl"
