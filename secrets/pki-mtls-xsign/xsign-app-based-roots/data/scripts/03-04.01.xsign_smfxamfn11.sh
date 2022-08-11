#!/bin/sh

## 

set -e
set -x

## SMF >>[XSIGN]>> AMF
#### AMF Root trusted by SMF Root
vault write pki_int_amf_n11/issuer/"$(vault write -format=json pki_int_amf_n11/issuers/import/bundle pem_bundle="$(vault write -field=certificate -format=json pki_root_smf/issuer/default/sign-intermediate csr="$(vault write -field=csr pki_root_amf/intermediate/generate/existing key_ref=default common_name="amf.5gc.mnc88.mcc888.3gppnetwork.org" max_path_length=1)" | jq -r '.' )" | jq -r '.data.imported_issuers[0]')" issuer_name="xsign_smfxamfn11"

################################
# SMF >>[XSIGN]>> AMF
## SMF Root CROSS SIGNS AMF Root
## AMF Root trusted by SMF Root
#vault write pki_int_amf_n11/issuer/"$(vault write -format=json pki_int_amf_n11/issuers/import/bundle pem_bundle="$(vault write -field=certificate -format=json pki_root_smf/issuer/default/sign-intermediate csr="$(vault write -field=csr pki_root_amf/intermediate/generate/existing key_ref=default common_name="amf.5gc.mnc88.mcc888.3gppnetwork.org" max_path_length=1)" | jq -r '.' )" | jq -r '.data.imported_issuers[0]')" issuer_name="xsign_smfxamfn11"

##### AMF Generates CSR from Existing CA Root
#vault write -format=json \
#    pki_root_amf/intermediate/generate/existing \
#    key_ref=default common_name="amf.5gc.mnc88.mcc888.3gppnetwork.org" \
#    max_path_length=1 \
#    | tee workspace/tmp/amf/xsign_smfxamfn11_csr.json
##    key_ref=$(jq -r '.data.key_id' < workspace/tmp/amf/pki_root_amf.cert.json )
##    ttl=2160h \
##    organization="5gc.mnc88.mcc888.3gppnetwork.org" \
#jq < workspace/tmp/amf/xsign_smfxamfn11_csr.json
#jq -r '.data.csr' < workspace/tmp/amf/xsign_smfxamfn11_csr.json > workspace/tmp/amf/xsign_smfxamfn11.csr
#cat workspace/tmp/amf/xsign_smfxamfn11.csr

##### SMF Signs AMF CSR and returns Certificate (PEM)
#vault write -format=json \
#    pki_root_smf/issuer/default/sign-intermediate \
#    csr=@workspace/tmp/amf/xsign_smfxamfn11.csr \
#    | tee workspace/tmp/amf/xsign_smfxamfn11_sign.json
##    csr=$(jq -r '.data.csr' < workspace/tmp/amf/xsign_smfxamfn11_csr.json )
#jq < workspace/tmp/amf/xsign_smfxamfn11_sign.json
#jq -r '.data.certificate' < workspace/tmp/amf/xsign_smfxamfn11_sign.json > workspace/tmp/amf/xsign_smfxamfn11.pem
#cat workspace/tmp/amf/xsign_smfxamfn11.pem

##### AMF Imports SMF Signed Certificate (PEM)
#vault write -format=json \
#    pki_int_amf_n11/issuers/import/bundle \
#    pem_bundle=@workspace/tmp/amf/xsign_smfxamfn11.pem \
#    | tee workspace/tmp/amf/xsign_smfxamfn11_import.json
##    pem_bundle=$(jq -r '.data.' < workspace/tmp/amf/xsign_smfxamfn11_sign.json )
#jq < workspace/tmp/amf/xsign_smfxamfn11_import.json
#jq -r '.data.imported_issuers[0]' < workspace/tmp/amf/xsign_smfxamfn11_import.json > workspace/tmp/amf/xsign_smfxamfn11_imported_issuer

##### Set AMF Issuer from Cross-Signed Chain
#vault write -format=json \
#    pki_int_amf_n11/issuer/$(jq -r '.data.imported_issuers[0]' < workspace/tmp/amf/xsign_smfxamfn11_import.json) \
#    issuer_name="xsign_smfxamfn11"
