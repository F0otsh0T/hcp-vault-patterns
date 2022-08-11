#!/bin/sh

## 

set -e
set -x

## NEF >>[XSIGN]>> AMF
#### AMF Root trusted by NEF Root
vault write pki_int_amf/issuer/"$(vault write -format=json pki_int_amf/issuers/import/bundle pem_bundle="$(vault write -field=certificate -format=json pki_root_nef/issuer/default/sign-intermediate csr="$(vault write -field=csr pki_root_amf/intermediate/generate/existing key_ref=default common_name="amf.5gc.mnc88.mcc888.3gppnetwork.org" max_path_length=1)" | jq -r '.' )" | jq -r '.data.imported_issuers[0]')" issuer_name="xsign_nefxamf"

################################
# NEF >>[XSIGN]>> AMF
## NEF Root CROSS SIGNS AMF Root
## AMF Root trusted by NEF Root
#vault write pki_int_amf/issuer/"$(vault write -format=json pki_int_amf/issuers/import/bundle pem_bundle="$(vault write -field=certificate -format=json pki_root_nef/issuer/default/sign-intermediate csr="$(vault write -field=csr pki_root_amf/intermediate/generate/existing key_ref=default common_name="amf.5gc.mnc88.mcc888.3gppnetwork.org" max_path_length=1)" | jq -r '.' )" | jq -r '.data.imported_issuers[0]')" issuer_name="xsign_nefxamf"

##### AMF Generates CSR from Existing CA Root
#vault write -format=json \
#    pki_root_amf/intermediate/generate/existing \
#    key_ref=default common_name="amf.5gc.mnc88.mcc888.3gppnetwork.org" \
#    max_path_length=1 \
#    | tee workspace/tmp/amf/xsign_nefxamf_csr.json
##    key_ref=$(jq -r '.data.key_id' < workspace/tmp/amf/pki_root_amf.cert.json )
##    ttl=2160h \
##    organization="5gc.mnc88.mcc888.3gppnetwork.org" \
#jq < workspace/tmp/amf/xsign_nefxamf_csr.json
#jq -r '.data.csr' < workspace/tmp/amf/xsign_nefxamf_csr.json > workspace/tmp/amf/xsign_nefxamf.csr
#cat workspace/tmp/amf/xsign_nefxamf.csr

##### NEF Signs AMF CSR and returns Certificate (PEM)
#vault write -format=json \
#    pki_root_nef/issuer/default/sign-intermediate \
#    csr=@workspace/tmp/amf/xsign_nefxamf.csr \
#    | tee workspace/tmp/amf/xsign_nefxamf_sign.json
##    csr=$(jq -r '.data.csr' < workspace/tmp/amf/xsign_nefxamf_csr.json )
#jq < workspace/tmp/amf/xsign_nefxamf_sign.json
#jq -r '.data.certificate' < workspace/tmp/amf/xsign_nefxamf_sign.json > workspace/tmp/amf/xsign_nefxamf.pem
#cat workspace/tmp/amf/xsign_nefxamf.pem

##### AMF Imports NEF Signed Certificate (PEM)
#vault write -format=json \
#    pki_int_amf/issuers/import/bundle \
#    pem_bundle=@workspace/tmp/amf/xsign_nefxamf.pem \
#    | tee workspace/tmp/amf/xsign_nefxamf_import.json
##    pem_bundle=$(jq -r '.data.' < workspace/tmp/amf/xsign_nefxamf_sign.json )
#jq < workspace/tmp/amf/xsign_nefxamf_import.json
#jq -r '.data.imported_issuers[0]' < workspace/tmp/amf/xsign_nefxamf_import.json > workspace/tmp/amf/xsign_nefxamf_imported_issuer

##### Set AMF Issuer from Cross-Signed Chain
#vault write -format=json \
#    pki_int_amf/issuer/$(jq -r '.data.imported_issuers[0]' < workspace/tmp/amf/xsign_nefxamf_import.json) \
#    issuer_name="xsign_nefxamf"
