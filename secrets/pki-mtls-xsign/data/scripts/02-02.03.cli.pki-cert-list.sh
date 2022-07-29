#!/bin/sh

set -e
set -x

vault list -format=json pki-root-client/certs | jq
vault list -format=json pki-root-server/certs | jq
