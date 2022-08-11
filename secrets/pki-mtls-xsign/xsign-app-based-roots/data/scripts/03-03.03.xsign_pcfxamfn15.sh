#!/bin/sh

## 

set -e
set -x

## PCF >>[XSIGN]>> SMF
#### SMF Root trusted by PCF Root
vault write pki_int_amf_n15/issuer/"$(vault write -format=json pki_int_amf_n15/issuers/import/bundle pem_bundle="$(vault write -field=certificate -format=json pki_root_pcf/issuer/default/sign-intermediate csr="$(vault write -field=csr pki_root_amf/intermediate/generate/existing key_ref=default common_name="amf.5gc.mnc88.mcc888.3gppnetwork.org" max_path_length=1)" | jq -r '.' )" | jq -r '.data.imported_issuers[0]')" issuer_name="xsign_pcfxamfn15"

################################
# PCF >>[XSIGN]>> SMF
## PCF Root CROSS SIGNS SMF Root
## SMF Root trusted by PCF Root
#vault write pki_int_amf_n15/issuer/"$(vault write -format=json pki_int_amf_n15/issuers/import/bundle pem_bundle="$(vault write -field=certificate -format=json pki_root_pcf/issuer/default/sign-intermediate csr="$(vault write -field=csr pki_root_amf/intermediate/generate/existing key_ref=default common_name="amf.5gc.mnc88.mcc888.3gppnetwork.org" max_path_length=1)" | jq -r '.' )" | jq -r '.data.imported_issuers[0]')" issuer_name="xsign_pcfxamfn15"

##### SMF Generates CSR from Existing CA Root
#vault write -format=json \
#    pki_root_amf/intermediate/generate/existing \
#    key_ref=default common_name="amf.5gc.mnc88.mcc888.3gppnetwork.org" \
#    max_path_length=1 \
#    | tee workspace/tmp/amf/xsign_pcfxamfn15_csr.json
##    key_ref=$(jq -r '.data.key_id' < workspace/tmp/amf/pki_root_amf.cert.json )
##    ttl=2160h \
##    organization="5gc.mnc88.mcc888.3gppnetwork.org" \
#jq < workspace/tmp/amf/xsign_pcfxamfn15_csr.json
#jq -r '.data.csr' < workspace/tmp/amf/xsign_pcfxamfn15_csr.json > workspace/tmp/amf/xsign_pcfxamfn15.csr
#cat workspace/tmp/amf/xsign_pcfxamfn15.csr

##### PCF Signs SMF CSR and returns Certificate (PEM)
#vault write -format=json \
#    pki_root_pcf/issuer/default/sign-intermediate \
#    csr=@workspace/tmp/amf/xsign_pcfxamfn15.csr \
#    | tee workspace/tmp/amf/xsign_pcfxamfn15_sign.json
##    csr=$(jq -r '.data.csr' < workspace/tmp/amf/xsign_pcfxamfn15_csr.json )
#jq < workspace/tmp/amf/xsign_pcfxamfn15_sign.json
#jq -r '.data.certificate' < workspace/tmp/amf/xsign_pcfxamfn15_sign.json > workspace/tmp/amf/xsign_pcfxamfn15.pem
#cat workspace/tmp/amf/xsign_pcfxamfn15.pem

##### SMF Imports PCF Signed Certificate (PEM)
#vault write -format=json \
#    pki_int_amf_n15/issuers/import/bundle \
#    pem_bundle=@workspace/tmp/amf/xsign_pcfxamfn15.pem \
#    | tee workspace/tmp/amf/xsign_pcfxamfn15_import.json
##    pem_bundle=$(jq -r '.data.' < workspace/tmp/amf/xsign_pcfxamfn15_sign.json )
#jq < workspace/tmp/amf/xsign_pcfxamfn15_import.json
#jq -r '.data.imported_issuers[0]' < workspace/tmp/amf/xsign_pcfxamfn15_import.json > workspace/tmp/amf/xsign_pcfxamfn15_imported_issuer

##### Set SMF Issuer from Cross-Signed Chain
#vault write -format=json \
#    pki_int_amf_n15/issuer/$(jq -r '.data.imported_issuers[0]' < workspace/tmp/amf/xsign_pcfxamfn15_import.json) \
#    issuer_name="xsign_pcfxamfn15"
