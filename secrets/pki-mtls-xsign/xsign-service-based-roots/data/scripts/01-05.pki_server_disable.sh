#!/bin/sh

set -e
set -x

# PKI CA Root Mounts - Disable

vault secrets disable amf_root
vault secrets disable amf_int
vault secrets disable nef_root
vault secrets disable nef_int
vault secrets disable pcf_root
vault secrets disable pcf_int
vault secrets disable pcf_root_n7
vault secrets disable pcf_int_n7
vault secrets disable pcf_root_n15
vault secrets disable pcf_int_n15
vault secrets disable smf_root
vault secrets disable smf_int
vault secrets disable smf_root_n11
vault secrets disable smf_int_n11
vault secrets disable smf_root_n29
vault secrets disable smf_int_n29
