#!/bin/sh

## 

set -e
set -x

## PCF >>[XSIGN]>> SMF
#### SMF Root trusted by PCF Root
vault write pki_int_smf_n7/issuer/"$(vault write -format=json pki_int_smf_n7/issuers/import/bundle pem_bundle="$(vault write -field=certificate -format=json pki_root_pcf/issuer/default/sign-intermediate csr="$(vault write -field=csr pki_root_smf/intermediate/generate/existing key_ref=default common_name="smf.5gc.mnc88.mcc888.3gppnetwork.org" max_path_length=1)" | jq -r '.' )" | jq -r '.data.imported_issuers[0]')" issuer_name="xsign_pcfxsmfn7"

################################
# PCF >>[XSIGN]>> SMF
## PCF Root CROSS SIGNS SMF Root
## SMF Root trusted by PCF Root
#vault write pki_int_smf_n7/issuer/"$(vault write -format=json pki_int_smf_n7/issuers/import/bundle pem_bundle="$(vault write -field=certificate -format=json pki_root_pcf/issuer/default/sign-intermediate csr="$(vault write -field=csr pki_root_smf/intermediate/generate/existing key_ref=default common_name="smf.5gc.mnc88.mcc888.3gppnetwork.org" max_path_length=1)" | jq -r '.' )" | jq -r '.data.imported_issuers[0]')" issuer_name="xsign_pcfxsmfn7"

##### SMF Generates CSR from Existing CA Root
#vault write -format=json \
#    pki_root_smf/intermediate/generate/existing \
#    key_ref=default common_name="smf.5gc.mnc88.mcc888.3gppnetwork.org" \
#    max_path_length=1 \
#    | tee workspace/tmp/smf/xsign_pcfxsmfn7_csr.json
##    key_ref=$(jq -r '.data.key_id' < workspace/tmp/smf/pki_root_smf.cert.json )
##    ttl=2160h \
##    organization="5gc.mnc88.mcc888.3gppnetwork.org" \
#jq < workspace/tmp/smf/xsign_pcfxsmfn7_csr.json
#jq -r '.data.csr' < workspace/tmp/smf/xsign_pcfxsmfn7_csr.json > workspace/tmp/smf/xsign_pcfxsmfn7.csr
#cat workspace/tmp/smf/xsign_pcfxsmfn7.csr

##### PCF Signs SMF CSR and returns Certificate (PEM)
#vault write -format=json \
#    pki_root_pcf/issuer/default/sign-intermediate \
#    csr=@workspace/tmp/smf/xsign_pcfxsmfn7.csr \
#    | tee workspace/tmp/smf/xsign_pcfxsmfn7_sign.json
##    csr=$(jq -r '.data.csr' < workspace/tmp/smf/xsign_pcfxsmfn7_csr.json )
#jq < workspace/tmp/smf/xsign_pcfxsmfn7_sign.json
#jq -r '.data.certificate' < workspace/tmp/smf/xsign_pcfxsmfn7_sign.json > workspace/tmp/smf/xsign_pcfxsmfn7.pem
#cat workspace/tmp/smf/xsign_pcfxsmfn7.pem

##### SMF Imports PCF Signed Certificate (PEM)
#vault write -format=json \
#    pki_int_smf_n7/issuers/import/bundle \
#    pem_bundle=@workspace/tmp/smf/xsign_pcfxsmfn7.pem \
#    | tee workspace/tmp/smf/xsign_pcfxsmfn7_import.json
##    pem_bundle=$(jq -r '.data.' < workspace/tmp/smf/xsign_pcfxsmfn7_sign.json )
#jq < workspace/tmp/smf/xsign_pcfxsmfn7_import.json
#jq -r '.data.imported_issuers[0]' < workspace/tmp/smf/xsign_pcfxsmfn7_import.json > workspace/tmp/smf/xsign_pcfxsmfn7_imported_issuer

##### Set SMF Issuer from Cross-Signed Chain
#vault write -format=json \
#    pki_int_smf_n7/issuer/$(jq -r '.data.imported_issuers[0]' < workspace/tmp/smf/xsign_pcfxsmfn7_import.json) \
#    issuer_name="xsign_pcfxsmfn7"
