#!/bin/sh

set -e
set -x

# PKI CA Root Mounts - Disable

vault secrets disable pki_root_amf
vault secrets disable pki_root_nef
vault secrets disable pki_root_pcf
vault secrets disable pki_root_smf
