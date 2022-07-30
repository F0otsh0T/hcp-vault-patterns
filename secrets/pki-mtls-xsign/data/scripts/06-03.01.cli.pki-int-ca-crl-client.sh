#!/bin/sh

set -e
set -x

export VAULT_ADDR_DOCKER='http://192.168.65.2:18200'
vault write pki-int-client/config/urls \
    issuing_certificates="${VAULT_ADDR_DOCKER}/v1/pki-int-client/ca,${VAULT_ADDR}/v1/pki-int-client/ca" \
    crl_distribution_points="${VAULT_ADDR_DOCKER}/v1/pki-int-client/crl,${VAULT_ADDR}/v1/pki-int-client/crl"
