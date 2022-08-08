#!/bin/sh
# Alex Scheel

set -e
set -x

docker stop mtlsx_carol_amf
docker stop mtlsx_alice_smf
docker stop mtlsx_bob_pcf

docker rm mtlsx_carol_amf
docker rm mtlsx_alice_smf
docker rm mtlsx_bob_pcf

vault secrets disable pki_root_amf
vault secrets disable pki_int_amf
vault secrets disable pki_root_smf
vault secrets disable pki_int_smf
vault secrets disable pki_root_pcf
vault secrets disable pki_int_pcf

rm *pem
rm *json
rm *html
rm *Containerfile
rm *config
rm *template

# VARS
export VAULT_ADDR_DOCKER='http://192.168.65.2:18200'
export VAULT_ADDR='http://127.0.0.1:18200'

# Set up basic PKI mounts

## AMF Root
vault secrets enable -path=pki_root_amf pki
vault secrets tune -max-lease-ttl=8760h pki_root_amf
vault write -format=json \
    pki_root_amf/root/generate/internal \
    common_name="amf.5gc.mnc88.mcc888.3gppnetwork.org" \
    max_path_length=2 \
    | tee pki_root_amf.cert.json
jq < pki_root_amf.cert.json
#    organization="5gc.mnc88.mcc888.3gppnetwork.org" \
#### AMF Root / Publish CA & CRL Endpoints
vault write -format=json \
    pki_root_amf/config/urls \
    issuing_certificates="${VAULT_ADDR_DOCKER}/v1/pki_root_amf/ca,${VAULT_ADDR}/v1/pki_root_amf/ca" \
    crl_distribution_points="${VAULT_ADDR_DOCKER}/v1/pki_root_amf/crl,${VAULT_ADDR}/v1/pki_root_amf/crl" \
    | tee pki_int_amf_ca_crl.json
jq < pki_int_amf_ca_crl.json

## AMF Int
vault secrets enable -path=pki_int_amf pki
vault write pki_int_amf/issuers/import/bundle pem_bundle="$(vault write -field=certificate -format=json pki_root_amf/issuer/default/sign-intermediate  csr="$(vault write -field=csr pki_int_amf/intermediate/generate/internal common_name="carol.amf.5gc.mnc88.mcc888.3gppnetwork.org" max_path_length=0 )" | jq -r '.')"
vault write pki_int_amf/issuer/default issuer_name="pki_int_amf"
# #### AMF Int / CSR
# vault write -format=json pki_int_amf/intermediate/generate/internal \
#     common_name="carol.amf.5gc.mnc88.mcc888.3gppnetwork.org" \
#     max_path_length=0 \
#     | jq > pki_int_amf.csr.json
# jq < pki_int_amf.csr.json
# jq -r '.data.csr' < pki_int_amf.csr.json
# #### AMF Int / Root Sign CSR
# vault write -format=json pki_root_amf/issuer/default/sign-intermediate \
#     csr="$(jq -r '.data.csr' < pki_int_amf.csr.json)" \
#     | jq > pki_int_amf.cert.json
# jq < pki_int_amf.cert.json
# jq -r '.data.certificate' < pki_int_amf.cert.json
# #### AMF Int / Import Root Signed PEM
# vault write -format=json pki_int_amf/issuers/import/bundle \
#     pem_bundle="$(jq -r '.data.certificate' < pki_int_amf.cert.json)" \
#     | jq > pki_int_amf.import.json
# #    pem_bundle="$(jq -r '.data.ca_chain' < pki_int_amf.cert.json)" \
# jq < pki_int_amf.import.json
# #### AMF Int / Update Issuer
# vault write -format=json pki_int_amf/issuer/default \
#     issuer_name="pki_int_amf" \
#     | jq > pki_int_amf.issuer.json
# jq < pki_int_amf.issuer.json
#### AMF Int / Publish CA & CRL Endpoints
vault write pki_int_amf/config/urls \
    issuing_certificates="${VAULT_ADDR_DOCKER}/v1/pki_int_amf/ca,${VAULT_ADDR}/v1/pki_int_amf/ca" \
    crl_distribution_points="${VAULT_ADDR_DOCKER}/v1/pki_int_amf/crl,${VAULT_ADDR}/v1/pki_int_amf/crl"
#    organization="5gc.mnc88.mcc888.3gppnetwork.org" \

## SMF Root
vault secrets enable -path=pki_root_smf pki
#### SMF Root / Generate Certificate
vault write -format=json pki_root_smf/root/generate/internal \
    common_name="smf.5gc.mnc88.mcc888.3gppnetwork.org" \
    max_path_length=2 \
    | jq > pki_root_smf.cert.json
#    organization="5gc.mnc88.mcc888.3gppnetwork.org" \
jq < pki_root_smf.cert.json
#### SMF Root / Publish CA & CRL Endpoints
vault write pki_root_smf/config/urls \
    issuing_certificates="${VAULT_ADDR_DOCKER}/v1/pki_root_smf/ca,${VAULT_ADDR}/v1/pki_root_smf/ca" \
    crl_distribution_points="${VAULT_ADDR_DOCKER}/v1/pki_root_smf/crl,${VAULT_ADDR}/v1/pki_root_smf/crl"

## SMF Int
vault secrets enable -path=pki_int_smf pki
vault write pki_int_smf/issuers/import/bundle pem_bundle="$(vault write -field=certificate -format=json pki_root_smf/issuer/default/sign-intermediate  csr="$(vault write -field=csr pki_int_smf/intermediate/generate/internal common_name="alice.smf.5gc.mnc88.mcc888.3gppnetwork.org" max_path_length=0 )" | jq -r '.')"
vault write pki_int_smf/issuer/default issuer_name="pki_int_smf"
# #### SMF Int / CSR
# vault write -format=json pki_int_smf/intermediate/generate/internal \
#     common_name="alice.smf.5gc.mnc88.mcc888.3gppnetwork.org" \
#     max_path_length=0 \
#     | jq > pki_int_smf.csr.json
# #    organization="5gc.mnc88.mcc888.3gppnetwork.org" \
# jq < pki_int_smf.csr.json
# jq -r '.data.csr' < pki_int_smf.csr.json
# #### SMF Int / Root Sign CSR
# vault write -format=json pki_root_smf/issuer/default/sign-intermediate \
#     csr="$(jq -r '.data.csr' < pki_int_smf.csr.json)" \
#     | jq > pki_int_smf.cert.json
# jq < pki_int_smf.cert.json
# jq -r '.data.certificate' < pki_int_smf.cert.json
# #### SMF Int / Import Root Signed PEM
# vault write -format=json pki_int_smf/issuers/import/bundle \
#     pem_bundle="$(jq -r '.data.certificate' < pki_int_smf.cert.json)" \
#     | jq > pki_int_smf.import.json
# #    pem_bundle="$(jq -r '.data.ca_chain' < pki_int_smf.cert.json)" \
# jq < pki_int_smf.import.json
# #### SMF Int / Update Issuer
# vault write -format=json pki_int_smf/issuer/default \
#     issuer_name="pki_int_smf" \
#     | jq > pki_int_smf.issuer.json
# jq < pki_int_smf.issuer.json
#### SMF Int / Publish CA & CRL Endpoints
vault write pki_int_smf/config/urls \
    issuing_certificates="${VAULT_ADDR_DOCKER}/v1/pki_int_smf/ca,${VAULT_ADDR}/v1/pki_int_smf/ca" \
    crl_distribution_points="${VAULT_ADDR_DOCKER}/v1/pki_int_smf/crl,${VAULT_ADDR}/v1/pki_int_smf/crl"

## PCF Root
vault secrets enable -path=pki_root_pcf pki
#### PCF Root / Generate Certificate
vault write -format=json pki_root_pcf/root/generate/internal \
    common_name="pcf.5gc.mnc88.mcc888.3gppnetwork.org" \
    max_path_length=2 \
    | jq > pki_root_pcf.cert.json
#    organization="5gc.mnc88.mcc888.3gppnetwork.org" \
jq < pki_root_pcf.cert.json
#### PCF Root / Publish CA & CRL Endpoints
vault write pki_root_pcf/config/urls \
    issuing_certificates="${VAULT_ADDR_DOCKER}/v1/pki_root_pcf/ca,${VAULT_ADDR}/v1/pki_root_pcf/ca" \
    crl_distribution_points="${VAULT_ADDR_DOCKER}/v1/pki_root_pcf/crl,${VAULT_ADDR}/v1/pki_root_pcf/crl"

## PCF Int
vault secrets enable -path=pki_int_pcf pki
vault write pki_int_pcf/issuers/import/bundle pem_bundle="$(vault write -field=certificate -format=json pki_root_pcf/issuer/default/sign-intermediate  csr="$(vault write -field=csr pki_int_pcf/intermediate/generate/internal common_name="bob.pcf.5gc.mnc88.mcc888.3gppnetwork.org" max_path_length=0 )" | jq -r '.')"
vault write pki_int_pcf/issuer/default issuer_name="pki_int_pcf"
# #### PCF Int / CSR
# vault write -format=json pki_int_pcf/intermediate/generate/internal \
#     common_name="bob.pcf.5gc.mnc88.mcc888.3gppnetwork.org" \
#     max_path_length=0 \
#     | jq > pki_int_pcf.csr.json
# #    organization="5gc.mnc88.mcc888.3gppnetwork.org" \
# jq < pki_int_pcf.csr.json
# jq -r '.data.csr' < pki_int_pcf.csr.json
# #### PCF Int / Root Sign CSR
# vault write -format=json pki_root_pcf/issuer/default/sign-intermediate \
#     csr="$(jq -r '.data.csr' < pki_int_pcf.csr.json)" \
#     | jq > pki_int_pcf.cert.json
# jq < pki_int_pcf.cert.json
# jq -r '.data.certificate' < pki_int_pcf.cert.json
# #### PCF Int / Import Root Signed PEM
# vault write -format=json pki_int_pcf/issuers/import/bundle \
#     pem_bundle="$(jq -r '.data.certificate' < pki_int_pcf.cert.json)" \
#     | jq > pki_int_pcf.import.json
# #    pem_bundle="$(jq -r '.data.ca_chain' < pki_int_pcf.cert.json)" \
# jq < pki_int_pcf.import.json
# #### PCF Int / Update Issuer
# vault write -format=json pki_int_pcf/issuer/default \
#     issuer_name="pki_int_pcf" \
#     | jq > pki_int_pcf.issuer.json
# jq < pki_int_pcf.issuer.json
#### PCF Int / Publish CA & CRL Endpoints
vault write pki_int_pcf/config/urls \
    issuing_certificates="${VAULT_ADDR_DOCKER}/v1/pki_int_pcf/ca,${VAULT_ADDR}/v1/pki_int_pcf/ca" \
    crl_distribution_points="${VAULT_ADDR_DOCKER}/v1/pki_int_pcf/crl,${VAULT_ADDR}/v1/pki_int_pcf/crl"

################################
# Start cross-signing:
# VM can talk to EB (and visa-versa)
# EB can talk to EA
# but VM can't (!!!) talk to EA

## SMF >>[XSIGN]>> PCF
#### PCF Root trusted by SMF Root
#vault write pki_int_pcf/issuer/"$(vault write -format=json pki_int_pcf/issuers/import/bundle pem_bundle="$(vault write -field=certificate -format=json pki_root_smf/issuer/default/sign-intermediate csr="$(vault write -field=csr pki_root_pcf/intermediate/generate/existing key_ref=default common_name="pcf.5gc.mnc88.mcc888.3gppnetwork.org" max_path_length=1)" | jq -r '.' )" | jq -r '.data.imported_issuers[0]')" issuer_name="xsign_smfxpcf"

## PCF >>[XSIGN]>> SMF
#### SMF Root trusted by PCF Root
vault write pki_int_smf/issuer/"$(vault write -format=json pki_int_smf/issuers/import/bundle pem_bundle="$(vault write -field=certificate -format=json pki_root_pcf/issuer/default/sign-intermediate csr="$(vault write -field=csr pki_root_smf/intermediate/generate/existing key_ref=default common_name="smf.5gc.mnc88.mcc888.3gppnetwork.org" max_path_length=1)" | jq -r '.' )" | jq -r '.data.imported_issuers[0]')" issuer_name="xsign_pcfxsmf"

## PCF >>[XSIGN]>> AMF
#### AMF Root trusted by PCF Root
vault write pki_int_amf/issuer/"$(vault write -format=json pki_int_amf/issuers/import/bundle pem_bundle="$(vault write -field=certificate -format=json pki_root_pcf/issuer/default/sign-intermediate csr="$(vault write -field=csr pki_root_amf/intermediate/generate/existing key_ref=default common_name="amf.5gc.mnc88.mcc888.3gppnetwork.org" max_path_length=1)" | jq -r '.' )" | jq -r '.data.imported_issuers[0]')" issuer_name="xsign_pcfxamf"

## AMF >>[XSIGN]>> PCF
#### PCF Root trusted by AMF Root
#vault write pki_int_pcf/issuer/"$(vault write -format=json pki_int_pcf/issuers/import/bundle pem_bundle="$(vault write -field=certificate -format=json pki_root_amf/issuer/default/sign-intermediate csr="$(vault write -field=csr pki_root_pcf/intermediate/generate/existing key_ref=default common_name="pcf.5gc.mnc88.mcc888.3gppnetwork.org" max_path_length=1)" | jq -r '.' )" | jq -r '.data.imported_issuers[0]')" issuer_name="xsign_amfxpcf"

## SMF >>[XSIGN]>> AMF
#### AMF Root trusted by SMF Root
#vault write pki_int_amf/issuer/"$(vault write -format=json pki_int_amf/issuers/import/bundle pem_bundle="$(vault write -field=certificate -format=json pki_root_smf/issuer/default/sign-intermediate csr="$(vault write -field=csr pki_root_amf/intermediate/generate/existing key_ref=default common_name="amf.5gc.mnc88.mcc888.3gppnetwork.org" max_path_length=1)" | jq -r '.' )" | jq -r '.data.imported_issuers[0]')" issuer_name="xsign_smfxamf"

## SMF >>[XSIGN]>> AMF
#### AMF Root trusted by SMF Root
vault write pki_int_amf/issuer/"$(vault write -format=json pki_int_amf/issuers/import/bundle pem_bundle="$(vault write -field=certificate -format=json pki_root_smf/issuer/default/sign-intermediate csr="$(vault write -field=csr pki_root_amf/intermediate/generate/existing key_ref=default common_name="amf.5gc.mnc88.mcc888.3gppnetwork.org" max_path_length=1)" | jq -r '.' )" | jq -r '.data.imported_issuers[0]')" issuer_name="xsign_smfxamf"

################################
# SMF >>[XSIGN]>> PCF
## SMF Root CROSS SIGNS PCF Root
## PCF Root trusted by SMF Root
#vault write pki_int_pcf/issuer/"$(vault write -format=json pki_int_pcf/issuers/import/bundle pem_bundle="$(vault write -field=certificate -format=json pki_root_smf/issuer/default/sign-intermediate csr="$(vault write -field=csr pki_root_pcf/intermediate/generate/existing key_ref=default common_name="pcf.5gc.mnc88.mcc888.3gppnetwork.org" max_path_length=1)" | jq -r '.' )" | jq -r '.data.imported_issuers[0]')" issuer_name="xsign_smfxpcf"
# #### PCF Generates CSR from Existing CA Root
# vault write -format=json \
#     pki_root_pcf/intermediate/generate/existing \
#     key_ref=default common_name="pcf.5gc.mnc88.mcc888.3gppnetwork.org" \
#     max_path_length=1 \
#     | tee xsign_smfxpcf_csr.json
# #    key_ref=$(jq -r '.data.key_id' < pki_root_pcf.cert.json )
# jq < xsign_smfxpcf_csr.json
# jq -r '.data.csr' < xsign_smfxpcf_csr.json > xsign_smfxpcf.csr
# cat xsign_smfxpcf.csr

# #### SMF Signs PCF CSR and returns Certificate (PEM)
# vault write -format=json \
#     pki_root_smf/issuer/default/sign-intermediate \
#     csr=@xsign_smfxpcf.csr \
#     | tee xsign_smfxpcf_sign.json
# #    csr=$(jq -r '.data.csr' < xsign_smfxpcf_csr.json )
# jq < xsign_smfxpcf_sign.json
# jq -r '.data.certificate' < xsign_smfxpcf_sign.json > xsign_smfxpcf.pem
# cat xsign_smfxpcf.pem

# #### PCF Imports SMF Signed Certificate (PEM)
# vault write -format=json \
#     pki_int_pcf/issuers/import/bundle \
#     pem_bundle=@xsign_smfxpcf.pem \
#     | tee xsign_smfxpcf_import.json
# #    pem_bundle=$(jq -r '.data.' < xsign_smfxpcf_sign.json )
# jq < xsign_smfxpcf_import.json
# jq -r '.data.imported_issuers[0]' < xsign_smfxpcf_import.json > xsign_smfxpcf_imported_issuer

# #### Set PCF Issuer from Cross-Signed Chain
# vault write -format=json \
#     pki_int_pcf/issuer/$(jq -r '.data.imported_issuers[0]' < xsign_smfxpcf_import.json) \
#     issuer_name="xsign_smfxpcf"

################################
# PCF >>[XSIGN]>> SMF
## PCF Root CROSS SIGNS SMF Root
## SMF Root trusted by PCF Root
#vault write pki_int_smf/issuer/"$(vault write -format=json pki_int_smf/issuers/import/bundle pem_bundle="$(vault write -field=certificate -format=json pki_root_pcf/issuer/default/sign-intermediate csr="$(vault write -field=csr pki_root_smf/intermediate/generate/existing key_ref=default common_name="smf.5gc.mnc88.mcc888.3gppnetwork.org" max_path_length=1)" | jq -r '.' )" | jq -r '.data.imported_issuers[0]')" issuer_name="xsign_pcfxsmf"
# #### SMF Generates CSR from Existing CA Root
# vault write -format=json \
#     pki_root_smf/intermediate/generate/existing \
#     key_ref=default common_name="smf.5gc.mnc88.mcc888.3gppnetwork.org" \
#     max_path_length=1 \
#     | tee xsign_pcfxsmf_csr.json
# #    key_ref=$(jq -r '.data.key_id' < pki_root_smf.cert.json )
# jq < xsign_pcfxsmf_csr.json
# jq -r '.data.csr' < xsign_pcfxsmf_csr.json > xsign_pcfxsmf.csr
# cat xsign_pcfxsmf.csr

# #### PCF Signs SMF CSR and returns Certificate (PEM)
# vault write -format=json \
#     pki_root_pcf/issuer/default/sign-intermediate \
#     csr=@xsign_pcfxsmf.csr \
#     | tee xsign_pcfxsmf_sign.json
# #    csr=$(jq -r '.data.csr' < xsign_pcfxsmf_csr.json )
# jq < xsign_pcfxsmf_sign.json
# jq -r '.data.certificate' < xsign_pcfxsmf_sign.json > xsign_pcfxsmf.pem
# cat xsign_pcfxsmf.pem

# #### SMF Imports PCF Signed Certificate (PEM)
# vault write -format=json \
#     pki_int_smf/issuers/import/bundle \
#     pem_bundle=@xsign_pcfxsmf.pem \
#     | tee xsign_pcfxsmf_import.json
# #    pem_bundle=$(jq -r '.data.' < xsign_pcfxsmf_sign.json )
# jq < xsign_pcfxsmf_import.json
# jq -r '.data.imported_issuers[0]' < xsign_pcfxsmf_import.json > xsign_pcfxsmf_imported_issuer

# #### Set SMF Issuer from Cross-Signed Chain
# vault write -format=json \
#     pki_int_smf/issuer/$(jq -r '.data.imported_issuers[0]' < xsign_pcfxsmf_import.json) \
#     issuer_name="xsign_pcfxsmf"

################################
# AMF >>[XSIGN]>> SMF
## AMF Root CROSS SIGNS SMF Root
## SMF Root trusted by AMF Root
#vault write pki_int_smf/issuer/"$(vault write -format=json pki_int_smf/issuers/import/bundle pem_bundle="$(vault write -field=certificate -format=json pki_root_amf/issuer/default/sign-intermediate csr="$(vault write -field=csr pki_root_smf/intermediate/generate/existing key_ref=default common_name="smf.5gc.mnc88.mcc888.3gppnetwork.org" max_path_length=1)" | jq -r '.' )" | jq -r '.data.imported_issuers[0]')" issuer_name="xsign_amfxsmf"
# #### SMF Generates CSR from Existing CA Root
# vault write -format=json \
#     pki_root_smf/intermediate/generate/existing \
#     key_ref=default common_name="smf.5gc.mnc88.mcc888.3gppnetwork.org" \
#     max_path_length=1 \
#     | tee xsign_amfxsmf_csr.json
# #    key_ref=$(jq -r '.data.key_id' < pki_root_smf.cert.json )
# jq < xsign_amfxsmf_csr.json
# jq -r '.data.csr' < xsign_amfxsmf_csr.json > xsign_amfxsmf.csr
# cat xsign_amfxsmf.csr

# #### AMF Signs SMF CSR and returns Certificate (PEM)
# vault write -format=json \
#     pki_root_amf/issuer/default/sign-intermediate \
#     csr=@xsign_amfxsmf.csr \
#     | tee xsign_amfxsmf_sign.json
# #    csr=$(jq -r '.data.csr' < xsign_amfxsmf_csr.json )
# jq < xsign_amfxsmf_sign.json
# jq -r '.data.certificate' < xsign_amfxsmf_sign.json > xsign_amfxsmf.pem
# cat xsign_amfxsmf.pem

# #### SMF Imports AMF Signed Certificate (PEM)
# vault write -format=json \
#     pki_int_smf/issuers/import/bundle \
#     pem_bundle=@xsign_amfxsmf.pem \
#     | tee xsign_amfxsmf_import.json
# #    pem_bundle=$(jq -r '.data.' < xsign_amfxsmf_sign.json )
# jq < xsign_amfxsmf_import.json
# jq -r '.data.imported_issuers[0]' < xsign_amfxsmf_import.json > xsign_amfxsmf_imported_issuer

# #### Set SMF Issuer from Cross-Signed Chain
# vault write -format=json \
#     pki_int_smf/issuer/$(jq -r '.data.imported_issuers[0]' < xsign_amfxsmf_import.json) \
#     issuer_name="xsign_amfxsmf"

################################
# SMF >>[XSIGN]>> AMF
## SMF Root CROSS SIGNS AMF Root
## AMF Root trusted by SMF Root
#vault write pki_int_amf/issuer/"$(vault write -format=json pki_int_amf/issuers/import/bundle pem_bundle="$(vault write -field=certificate -format=json pki_root_smf/issuer/default/sign-intermediate csr="$(vault write -field=csr pki_root_amf/intermediate/generate/existing key_ref=default common_name="amf.5gc.mnc88.mcc888.3gppnetwork.org" max_path_length=1)" | jq -r '.' )" | jq -r '.data.imported_issuers[0]')" issuer_name="xsign_smfxamf"
# #### AMF Generates CSR from Existing CA Root
# vault write -format=json \
#     pki_root_amf/intermediate/generate/existing \
#     key_ref=default common_name="amf.5gc.mnc88.mcc888.3gppnetwork.org" \
#     max_path_length=1 \
#     | tee xsign_smfxamf_csr.json
# #    key_ref=$(jq -r '.data.key_id' < pki_root_amf.cert.json )
# jq < xsign_smfxamf_csr.json
# jq -r '.data.csr' < xsign_smfxamf_csr.json > xsign_smfxamf.csr
# cat xsign_smfxamf.csr

# #### SMF Signs AMF CSR and returns Certificate (PEM)
# vault write -format=json \
#     pki_root_smf/issuer/default/sign-intermediate \
#     csr=@xsign_smfxamf.csr \
#     | tee xsign_smfxamf_sign.json
# #    csr=$(jq -r '.data.csr' < xsign_smfxamf_csr.json )
# jq < xsign_smfxamf_sign.json
# jq -r '.data.certificate' < xsign_smfxamf_sign.json > xsign_smfxamf.pem
# cat xsign_smfxamf.pem

# #### AMF Imports SMF Signed Certificate (PEM)
# vault write -format=json \
#     pki_int_amf/issuers/import/bundle \
#     pem_bundle=@xsign_smfxamf.pem \
#     | tee xsign_smfxamf_import.json
# #    pem_bundle=$(jq -r '.data.' < xsign_smfxamf_sign.json )
# jq < xsign_smfxamf_import.json
# jq -r '.data.imported_issuers[0]' < xsign_smfxamf_import.json > xsign_smfxamf_imported_issuer

# #### Set AMF Issuer from Cross-Signed Chain
# vault write -format=json \
#     pki_int_amf/issuer/$(jq -r '.data.imported_issuers[0]' < xsign_smfxamf_import.json) \
#     issuer_name="xsign_smfxamf"

################################
# PCF >>[XSIGN]>> AMF
## PCF Root CROSS SIGNS AMF Root
## AMF Root trusted by PCF Root
#vault write pki_int_amf/issuer/"$(vault write -format=json pki_int_amf/issuers/import/bundle pem_bundle="$(vault write -field=certificate -format=json pki_root_pcf/issuer/default/sign-intermediate csr="$(vault write -field=csr pki_root_amf/intermediate/generate/existing key_ref=default common_name="amf.5gc.mnc88.mcc888.3gppnetwork.org" max_path_length=1)" | jq -r '.' )" | jq -r '.data.imported_issuers[0]')" issuer_name="xsign_pcfxamf"
# #### AMF Generates CSR from Existing CA Root
# vault write -format=json \
#     pki_root_amf/intermediate/generate/existing \
#     key_ref=default common_name="amf.5gc.mnc88.mcc888.3gppnetwork.org" \
#     max_path_length=1 \
#     | tee xsign_pcfxamf_csr.json
# #    key_ref=$(jq -r '.data.key_id' < pki_root_amf.cert.json )
# jq < xsign_pcfxamf_csr.json
# jq -r '.data.csr' < xsign_pcfxamf_csr.json > xsign_pcfxamf.csr
# cat xsign_pcfxamf.csr

# #### PCF Signs AMF CSR and returns Certificate (PEM)
# vault write -format=json \
#     pki_root_pcf/issuer/default/sign-intermediate \
#     csr=@xsign_pcfxamf.csr \
#     | tee xsign_pcfxamf_sign.json
# #    csr=$(jq -r '.data.csr' < xsign_pcfxamf_csr.json )
# jq < xsign_pcfxamf_sign.json
# jq -r '.data.certificate' < xsign_pcfxamf_sign.json > xsign_pcfxamf.pem
# cat xsign_pcfxamf.pem

# #### AMF Imports PCF Signed Certificate (PEM)
# vault write -format=json \
#     pki_int_amf/issuers/import/bundle \
#     pem_bundle=@xsign_pcfxamf.pem \
#     | tee xsign_pcfxamf_import.json
# #    pem_bundle=$(jq -r '.data.' < xsign_pcfxamf_sign.json )
# jq < xsign_pcfxamf_import.json
# jq -r '.data.imported_issuers[0]' < xsign_pcfxamf_import.json > xsign_pcfxamf_imported_issuer

# #### Set AMF Issuer from Cross-Signed Chain
# vault write -format=json \
#     pki_int_amf/issuer/$(jq -r '.data.imported_issuers[0]' < xsign_pcfxamf_import.json) \
#     issuer_name="xsign_pcfxamf"

################################
# AMF >>[XSIGN]>> PCF
## AMF Root CROSS SIGNS PCF Root
## PCF Root trusted by AMF Root
#vault write pki_int_pcf/issuer/"$(vault write -format=json pki_int_pcf/issuers/import/bundle pem_bundle="$(vault write -field=certificate -format=json pki_root_amf/issuer/default/sign-intermediate csr="$(vault write -field=csr pki_root_pcf/intermediate/generate/existing key_ref=default common_name="pcf.5gc.mnc88.mcc888.3gppnetwork.org" max_path_length=1)" | jq -r '.' )" | jq -r '.data.imported_issuers[0]')" issuer_name="xsign_amfxpcf"
# #### PCF Generates CSR from Existing CA Root
# vault write -format=json \
#     pki_root_pcf/intermediate/generate/existing \
#     key_ref=default common_name="pcf.5gc.mnc88.mcc888.3gppnetwork.org" \
#     max_path_length=1 \
#     | tee xsign_amfxpcf_csr.json
# #    key_ref=$(jq -r '.data.key_id' < pki_root_pcf.cert.json )
# jq < xsign_amfxpcf_csr.json
# jq -r '.data.csr' < xsign_amfxpcf_csr.json > xsign_amfxpcf.csr
# cat xsign_amfxpcf.csr

# #### AMF Signs PCF CSR and returns Certificate (PEM)
# vault write -format=json \
#     pki_root_amf/issuer/default/sign-intermediate \
#     csr=@xsign_amfxpcf.csr \
#     | tee xsign_amfxpcf_sign.json
# #    csr=$(jq -r '.data.csr' < xsign_amfxpcf_csr.json )
# jq < xsign_amfxpcf_sign.json
# jq -r '.data.certificate' < xsign_amfxpcf_sign.json > xsign_amfxpcf.pem
# cat xsign_amfxpcf.pem

# #### PCF Imports AMF Signed Certificate (PEM)
# vault write -format=json \
#     pki_int_pcf/issuers/import/bundle \
#     pem_bundle=@xsign_amfxpcf.pem \
#     | tee xsign_amfxpcf_import.json
# #    pem_bundle=$(jq -r '.data.' < xsign_amfxpcf_sign.json )
# jq < xsign_amfxpcf_import.json
# jq -r '.data.imported_issuers[0]' < xsign_amfxpcf_import.json > xsign_amfxpcf_imported_issuer

# #### Set PCF Issuer from Cross-Signed Chain
# vault write -format=json \
#     pki_int_pcf/issuer/$(jq -r '.data.imported_issuers[0]' < xsign_amfxpcf_import.json) \
#     issuer_name="xsign_amfxpcf"

################################
# ROLES
# Now we want to do roles
################################

vault write pki_int_amf/roles/client allow_any_name=true enforce_hostnames=false server_flag=false client_flag=true ttl=28d
vault write pki_int_amf/roles/server allow_any_name=true enforce_hostnames=false server_flag=true client_flag=false ttl=28d
vault write pki_int_smf/roles/client allow_any_name=true enforce_hostnames=false server_flag=false client_flag=true ttl=28d
vault write pki_int_smf/roles/server allow_any_name=true enforce_hostnames=false server_flag=true client_flag=false ttl=28d
vault write pki_int_pcf/roles/client allow_any_name=true enforce_hostnames=false server_flag=false client_flag=true ttl=28d
vault write pki_int_pcf/roles/server allow_any_name=true enforce_hostnames=false server_flag=true client_flag=false ttl=28d

# Now we want to issue leaves

## AMF Charlie (client, server)
## carol.amf.5gc.mnc88.mcc888.3gppnetwork.org
vault write -format=json pki_int_amf/issue/client common_name="client.carol.amf.5gc.mnc88.mcc888.3gppnetwork.org" > pki_int_amf_client.cert.json
vault write -format=json pki_int_amf/issue/server common_name="server.carol.amf.5gc.mnc88.mcc888.3gppnetwork.org" > pki_int_amf_server.cert.json

jq -r '.data.certificate' < pki_int_amf_server.cert.json > amf_server_cert.pem
jq -r '.data.certificate' < pki_int_amf_server.cert.json > amf_server_chain.pem
jq -r '.data.ca_chain | join("\n")' < pki_int_amf_server.cert.json >> amf_server_chain.pem
jq -r '.data.private_key' < pki_int_amf_server.cert.json > amf_server_key.pem

jq -r '.data.certificate' < pki_int_amf_client.cert.json > amf_client_cert.pem
jq -r '.data.certificate' < pki_int_amf_client.cert.json > amf_client_chain.pem
jq -r '.data.ca_chain | join("\n")' < pki_int_amf_client.cert.json >> amf_client_chain.pem
jq -r '.data.private_key' < pki_int_amf_client.cert.json > amf_client_key.pem

vault read -field=certificate pki_root_amf/issuer/default > amf_root.pem

## SMF Alice (client, server)
# alice.smf.5gc.mnc88.mcc888.3gppnetwork.org
vault write -format=json pki_int_smf/issue/client common_name="client.alice.smf.5gc.mnc88.mcc888.3gppnetwork.org" > pki_int_smf_client.cert.json
vault write -format=json pki_int_smf/issue/server common_name="server.alice.smf.5gc.mnc88.mcc888.3gppnetwork.org" > pki_int_smf_server.cert.json

jq -r '.data.certificate' < pki_int_smf_server.cert.json > smf_server_cert.pem
jq -r '.data.certificate' < pki_int_smf_server.cert.json > smf_server_chain.pem
jq -r '.data.ca_chain | join("\n")' < pki_int_smf_server.cert.json >> smf_server_chain.pem
jq -r '.data.private_key' < pki_int_smf_server.cert.json > smf_server_key.pem

jq -r '.data.certificate' < pki_int_smf_client.cert.json > smf_client_cert.pem
jq -r '.data.certificate' < pki_int_smf_client.cert.json > smf_client_chain.pem
jq -r '.data.ca_chain | join("\n")' < pki_int_smf_client.cert.json >> smf_client_chain.pem
jq -r '.data.private_key' < pki_int_smf_client.cert.json > smf_client_key.pem

vault read -field=certificate pki_root_smf/issuer/default > smf_root.pem

## PCF Bob (client, server)
# bob.pcf.5gc.mnc88.mcc888.3gppnetwork.org
vault write -format=json pki_int_pcf/issue/client common_name="client.bob.pcf.5gc.mnc88.mcc888.3gppnetwork.org" > pki_int_bob_client.cert.json
vault write -format=json pki_int_pcf/issue/server common_name="server.bob.pcf.5gc.mnc88.mcc888.3gppnetwork.org" > pki_int_bob_server.cert.json

jq -r '.data.certificate' < pki_int_bob_server.cert.json > pcf_server_cert.pem
jq -r '.data.certificate' < pki_int_bob_server.cert.json > pcf_server_chain.pem
jq -r '.data.ca_chain | join("\n")' < pki_int_bob_server.cert.json >> pcf_server_chain.pem
jq -r '.data.private_key' < pki_int_bob_server.cert.json > pcf_server_key.pem

jq -r '.data.certificate' < pki_int_bob_client.cert.json > pcf_client_cert.pem
jq -r '.data.certificate' < pki_int_bob_client.cert.json > pcf_client_chain.pem
jq -r '.data.ca_chain | join("\n")' < pki_int_bob_client.cert.json >> pcf_client_chain.pem
jq -r '.data.private_key' < pki_int_bob_client.cert.json > pcf_client_key.pem

vault read -field=certificate pki_root_pcf/issuer/default > pcf_root.pem

# Now we build Docker images...
echo '
server {
    listen LISTENNOTLSREPLACE;
    listen LISTENTLSREPLACE ssl;

    ssl_protocols TLSv1.2;

    ssl_certificate /etc/server-chain.pem;
    ssl_certificate_key /etc/server-key.pem;
    
    ssl_client_certificate /etc/ca.pem;
    
    ssl_verify_client on;
    ssl_verify_depth 8;

    if ($ssl_client_verify != SUCCESS) {
        return 402;
    }

    location / {
        root   /usr/share/nginx/html;
        index  index.html index.htm;
        autoindex on;

        if ($ssl_client_verify != SUCCESS) {
                return 403;
        }
    }

    error_page   500 502 503 504  /50x.html;
    location = /50x.html {
        root   /usr/share/nginx/html;
    }
}
' > nginx.conf.template

# sed 's/LISTENNOTLSREPLACE/8080/g' nginx.conf.template | sed 's/LISTENTLSREPLACE/8443/g' > nginx-eb.config
# sed 's/LISTENNOTLSREPLACE/8081/g' nginx.conf.template | sed 's/LISTENTLSREPLACE/8444/g' > nginx-vm.config
# sed 's/LISTENNOTLSREPLACE/8082/g' nginx.conf.template | sed 's/LISTENTLSREPLACE/8445/g' > nginx-ea.config

sed 's/LISTENNOTLSREPLACE/20080/g' nginx.conf.template | sed 's/LISTENTLSREPLACE/20443/g' > nginx-ea.config
sed 's/LISTENNOTLSREPLACE/21080/g' nginx.conf.template | sed 's/LISTENTLSREPLACE/21443/g' > nginx-eb.config
sed 's/LISTENNOTLSREPLACE/22080/g' nginx.conf.template | sed 's/LISTENTLSREPLACE/22443/g' > nginx-vm.config

echo '<html><body><h1>It works - AMF!</h1></body></html>' > index-ea.html
echo '<html><body><h1>It works - SMF!</h1></body></html>' > index-eb.html
echo '<html><body><h1>It works - PCF!</h1></body></html>' > index-vm.html

echo '
FROM docker.io/nginxinc/nginx-unprivileged
COPY nginx-INDEXREPLACE.config /etc/nginx/conf.d/default.conf
COPY index-INDEXREPLACE.html /usr/share/nginx/html/index.html
COPY CHAINREPLACE.pem /etc/server-chain.pem
COPY KEYREPLACE.pem /etc/server-key.pem
COPY CAREPLACE.pem /etc/ca.pem
COPY *.pem /var/tmp/
' > Containerfile.template

sed 's/CHAINREPLACE/amf_server_chain/g' Containerfile.template | sed 's/KEYREPLACE/amf_server_key/g' | sed 's/CAREPLACE/amf_root/g' | sed 's/INDEXREPLACE/ea/g' > mtlsx_carol_amf.Containerfile
sed 's/CHAINREPLACE/smf_server_chain/g' Containerfile.template | sed 's/KEYREPLACE/smf_server_key/g' | sed 's/CAREPLACE/smf_root/g' | sed 's/INDEXREPLACE/eb/g' > mtlsx_alice_smf.Containerfile
sed 's/CHAINREPLACE/pcf_server_chain/g' Containerfile.template | sed 's/KEYREPLACE/pcf_server_key/g' | sed 's/CAREPLACE/pcf_root/g' | sed 's/INDEXREPLACE/vm/g' > mtlsx_bob_pcf.Containerfile

# buildah bud -f mtlsx_carol_amf.Containerfile -t mtlsx_carol_amf:latest .
# buildah bud -f mtlsx_alice_smf.Containerfile -t mtlsx_alice_smf:latest .
# buildah bud -f mtlsx_bob_pcf.Containerfile -t mtlsx_bob_pcf:latest .

docker build -f mtlsx_carol_amf.Containerfile -t mtlsx_carol_amf:latest .
docker build -f mtlsx_alice_smf.Containerfile -t mtlsx_alice_smf:latest .
docker build -f mtlsx_bob_pcf.Containerfile -t mtlsx_bob_pcf:latest .

# podman run --network=host mtlsx_carol_amf:latest
# podman run --network=host mtlsx_alice_smf:latest
# podman run --network=host mtlsx_bob_pcf:latest

docker run -d --privileged -p 20080:20080 -p 20443:20443 --name mtlsx_carol_amf mtlsx_carol_amf:latest
docker run -d --privileged -p 21080:21080 -p 21443:21443 --name mtlsx_alice_smf mtlsx_alice_smf:latest
docker run -d --privileged -p 22080:22080 -p 22443:22443 --name mtlsx_bob_pcf mtlsx_bob_pcf:latest
