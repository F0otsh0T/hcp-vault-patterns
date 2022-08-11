#!/bin/sh

## 

set -e
set -x

## NEF >>[XSIGN]>> SMF
#### SMF Root trusted by NEF Root
vault write pki_int_smf/issuer/"$(vault write -format=json pki_int_smf/issuers/import/bundle pem_bundle="$(vault write -field=certificate -format=json pki_root_nef/issuer/default/sign-intermediate csr="$(vault write -field=csr pki_root_smf/intermediate/generate/existing key_ref=default common_name="smf.5gc.mnc88.mcc888.3gppnetwork.org" max_path_length=1)" | jq -r '.' )" | jq -r '.data.imported_issuers[0]')" issuer_name="xsign_nefxsmf"

################################
# NEF >>[XSIGN]>> SMF
## NEF Root CROSS SIGNS SMF Root
## SMF Root trusted by NEF Root
#vault write pki_int_smf/issuer/"$(vault write -format=json pki_int_smf/issuers/import/bundle pem_bundle="$(vault write -field=certificate -format=json pki_root_nef/issuer/default/sign-intermediate csr="$(vault write -field=csr pki_root_smf/intermediate/generate/existing key_ref=default common_name="smf.5gc.mnc88.mcc888.3gppnetwork.org" max_path_length=1)" | jq -r '.' )" | jq -r '.data.imported_issuers[0]')" issuer_name="xsign_nefxsmf"

##### SMF Generates CSR from Existing CA Root
#vault write -format=json \
#    pki_root_smf/intermediate/generate/existing \
#    key_ref=default common_name="smf.5gc.mnc88.mcc888.3gppnetwork.org" \
#    max_path_length=1 \
#    | tee workspace/tmp/smf/xsign_nefxsmf_csr.json
##    key_ref=$(jq -r '.data.key_id' < workspace/tmp/smf/pki_root_smf.cert.json )
##    ttl=2160h \
##    organization="5gc.mnc88.mcc888.3gppnetwork.org" \
#jq < workspace/tmp/smf/xsign_nefxsmf_csr.json
#jq -r '.data.csr' < workspace/tmp/smf/xsign_nefxsmf_csr.json > workspace/tmp/smf/xsign_nefxsmf.csr
#cat workspace/tmp/smf/xsign_nefxsmf.csr

##### NEF Signs SMF CSR and returns Certificate (PEM)
#vault write -format=json \
#    pki_root_nef/issuer/default/sign-intermediate \
#    csr=@workspace/tmp/smf/xsign_nefxsmf.csr \
#    | tee workspace/tmp/smf/xsign_nefxsmf_sign.json
##    csr=$(jq -r '.data.csr' < workspace/tmp/smf/xsign_nefxsmf_csr.json )
#jq < workspace/tmp/smf/xsign_nefxsmf_sign.json
#jq -r '.data.certificate' < workspace/tmp/smf/xsign_nefxsmf_sign.json > workspace/tmp/smf/xsign_nefxsmf.pem
#cat workspace/tmp/smf/xsign_nefxsmf.pem

##### SMF Imports NEF Signed Certificate (PEM)
#vault write -format=json \
#    pki_int_smf/issuers/import/bundle \
#    pem_bundle=@workspace/tmp/smf/xsign_nefxsmf.pem \
#    | tee workspace/tmp/smf/xsign_nefxsmf_import.json
##    pem_bundle=$(jq -r '.data.' < workspace/tmp/smf/xsign_nefxsmf_sign.json )
#jq < workspace/tmp/smf/xsign_nefxsmf_import.json
#jq -r '.data.imported_issuers[0]' < workspace/tmp/smf/xsign_nefxsmf_import.json > workspace/tmp/smf/xsign_nefxsmf_imported_issuer

##### Set SMF Issuer from Cross-Signed Chain
#vault write -format=json \
#    pki_int_smf/issuer/$(jq -r '.data.imported_issuers[0]' < workspace/tmp/smf/xsign_nefxsmf_import.json) \
#    issuer_name="xsign_nefxsmf"
