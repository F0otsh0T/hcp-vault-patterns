#!/bin/sh

## 

set -e
set -x

## AMF >>[XSIGN]>> PCF
#### PCF Root trusted by AMF Root
vault write pki_int_pcf/issuer/"$(vault write -format=json pki_int_pcf/issuers/import/bundle pem_bundle="$(vault write -field=certificate -format=json pki_root_amf/issuer/default/sign-intermediate csr="$(vault write -field=csr pki_root_pcf/intermediate/generate/existing key_ref=default common_name="pcf.5gc.mnc88.mcc888.3gppnetwork.org" max_path_length=1)" | jq -r '.' )" | jq -r '.data.imported_issuers[0]')" issuer_name="xsign_amfxpcf"

################################
# AMF >>[XSIGN]>> PCF
## AMF Root CROSS SIGNS PCF Root
## PCF Root trusted by AMF Root
#vault write pki_int_pcf/issuer/"$(vault write -format=json pki_int_pcf/issuers/import/bundle pem_bundle="$(vault write -field=certificate -format=json pki_root_amf/issuer/default/sign-intermediate csr="$(vault write -field=csr pki_root_pcf/intermediate/generate/existing key_ref=default common_name="pcf.5gc.mnc88.mcc888.3gppnetwork.org" max_path_length=1)" | jq -r '.' )" | jq -r '.data.imported_issuers[0]')" issuer_name="xsign_amfxpcf"

##### PCF Generates CSR from Existing CA Root
#vault write -format=json \
#    pki_root_pcf/intermediate/generate/existing \
#    key_ref=default common_name="pcf.5gc.mnc88.mcc888.3gppnetwork.org" \
#    max_path_length=1 \
#    | tee workspace/tmp/pcf/xsign_amfxpcf_csr.json
##    key_ref=$(jq -r '.data.key_id' < workspace/tmp/pcf/pki_root_pcf.cert.json )
##    ttl=2160h \
##    organization="5gc.mnc88.mcc888.3gppnetwork.org" \
#jq < workspace/tmp/pcf/xsign_amfxpcf_csr.json
#jq -r '.data.csr' < workspace/tmp/pcf/xsign_amfxpcf_csr.json > workspace/tmp/pcf/xsign_amfxpcf.csr
#cat workspace/tmp/pcf/xsign_amfxpcf.csr

##### AMF Signs PCF CSR and returns Certificate (PEM)
#vault write -format=json \
#    pki_root_amf/issuer/default/sign-intermediate \
#    csr=@workspace/tmp/pcf/xsign_amfxpcf.csr \
#    | tee workspace/tmp/pcf/xsign_amfxpcf_sign.json
##    csr=$(jq -r '.data.csr' < workspace/tmp/pcf/xsign_amfxpcf_csr.json )
#jq < workspace/tmp/pcf/xsign_amfxpcf_sign.json
#jq -r '.data.certificate' < workspace/tmp/pcf/xsign_amfxpcf_sign.json > workspace/tmp/pcf/xsign_amfxpcf.pem
#cat workspace/tmp/pcf/xsign_amfxpcf.pem

##### PCF Imports AMF Signed Certificate (PEM)
#vault write -format=json \
#    pki_int_pcf/issuers/import/bundle \
#    pem_bundle=@workspace/tmp/pcf/xsign_amfxpcf.pem \
#    | tee workspace/tmp/pcf/xsign_amfxpcf_import.json
##    pem_bundle=$(jq -r '.data.' < workspace/tmp/pcf/xsign_amfxpcf_sign.json )
#jq < workspace/tmp/pcf/xsign_amfxpcf_import.json
#jq -r '.data.imported_issuers[0]' < workspace/tmp/pcf/xsign_amfxpcf_import.json > workspace/tmp/pcf/xsign_amfxpcf_imported_issuer

##### Set PCF Issuer from Cross-Signed Chain
#vault write -format=json \
#    pki_int_pcf/issuer/$(jq -r '.data.imported_issuers[0]' < workspace/tmp/pcf/xsign_amfxpcf_import.json) \
#    issuer_name="xsign_amfxpcf"
