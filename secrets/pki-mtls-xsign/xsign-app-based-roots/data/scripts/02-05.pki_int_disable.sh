#!/bin/sh

set -e
set -x

# PKI CA Intermediate Mounts - Disable

vault secrets disable pki_int_amf
vault secrets disable pki_int_amf_n11
vault secrets disable pki_int_amf_n15
vault secrets disable pki_int_nef
vault secrets disable pki_int_nef_n29
vault secrets disable pki_int_pcf
vault secrets disable pki_int_smf
vault secrets disable pki_int_smf_n7
