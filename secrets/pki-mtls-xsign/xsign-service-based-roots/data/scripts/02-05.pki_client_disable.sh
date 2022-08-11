#!/bin/sh

set -e
set -x

# PKI CA Root Mounts - Disable

vault secrets disable amf_int_n11
vault secrets disable amf_int_n15
vault secrets disable nef_int_n29
vault secrets disable smf_int_n7
