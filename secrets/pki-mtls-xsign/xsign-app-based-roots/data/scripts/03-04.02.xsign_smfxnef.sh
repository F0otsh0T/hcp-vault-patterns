#!/bin/sh

## 

set -e
set -x

## SMF >>[XSIGN]>> NEF
#### NEF Root trusted by SMF Root
vault write pki_int_nef/issuer/"$(vault write -format=json pki_int_nef/issuers/import/bundle pem_bundle="$(vault write -field=certificate -format=json pki_root_smf/issuer/default/sign-intermediate csr="$(vault write -field=csr pki_root_nef/intermediate/generate/existing key_ref=default common_name="nef.5gc.mnc88.mcc888.3gppnetwork.org" max_path_length=1)" | jq -r '.' )" | jq -r '.data.imported_issuers[0]')" issuer_name="xsign_smfxnef"

################################
# SMF >>[XSIGN]>> NEF
## SMF Root CROSS SIGNS NEF Root
## NEF Root trusted by SMF Root
#vault write pki_int_nef/issuer/"$(vault write -format=json pki_int_nef/issuers/import/bundle pem_bundle="$(vault write -field=certificate -format=json pki_root_smf/issuer/default/sign-intermediate csr="$(vault write -field=csr pki_root_nef/intermediate/generate/existing key_ref=default common_name="nef.5gc.mnc88.mcc888.3gppnetwork.org" max_path_length=1)" | jq -r '.' )" | jq -r '.data.imported_issuers[0]')" issuer_name="xsign_smfxnef"

##### NEF Generates CSR from Existing CA Root
#vault write -format=json \
#    pki_root_nef/intermediate/generate/existing \
#    key_ref=default common_name="nef.5gc.mnc88.mcc888.3gppnetwork.org" \
#    max_path_length=1 \
#    | tee workspace/tmp/nef/xsign_smfxnef_csr.json
##    key_ref=$(jq -r '.data.key_id' < workspace/tmp/nef/pki_root_nef.cert.json )
##    ttl=2160h \
##    organization="5gc.mnc88.mcc888.3gppnetwork.org" \
#jq < workspace/tmp/nef/xsign_smfxnef_csr.json
#jq -r '.data.csr' < workspace/tmp/nef/xsign_smfxnef_csr.json > workspace/tmp/nef/xsign_smfxnef.csr
#cat workspace/tmp/nef/xsign_smfxnef.csr

##### SMF Signs NEF CSR and returns Certificate (PEM)
#vault write -format=json \
#    pki_root_smf/issuer/default/sign-intermediate \
#    csr=@workspace/tmp/nef/xsign_smfxnef.csr \
#    | tee workspace/tmp/nef/xsign_smfxnef_sign.json
##    csr=$(jq -r '.data.csr' < workspace/tmp/nef/xsign_smfxnef_csr.json )
#jq < workspace/tmp/nef/xsign_smfxnef_sign.json
#jq -r '.data.certificate' < workspace/tmp/nef/xsign_smfxnef_sign.json > workspace/tmp/nef/xsign_smfxnef.pem
#cat workspace/tmp/nef/xsign_smfxnef.pem

##### NEF Imports SMF Signed Certificate (PEM)
#vault write -format=json \
#    pki_int_nef/issuers/import/bundle \
#    pem_bundle=@workspace/tmp/nef/xsign_smfxnef.pem \
#    | tee workspace/tmp/nef/xsign_smfxnef_import.json
##    pem_bundle=$(jq -r '.data.' < workspace/tmp/nef/xsign_smfxnef_sign.json )
#jq < workspace/tmp/nef/xsign_smfxnef_import.json
#jq -r '.data.imported_issuers[0]' < workspace/tmp/nef/xsign_smfxnef_import.json > workspace/tmp/nef/xsign_smfxnef_imported_issuer

##### Set NEF Issuer from Cross-Signed Chain
#vault write -format=json \
#    pki_int_nef/issuer/$(jq -r '.data.imported_issuers[0]' < workspace/tmp/nef/xsign_smfxnef_import.json) \
#    issuer_name="xsign_smfxnef"
