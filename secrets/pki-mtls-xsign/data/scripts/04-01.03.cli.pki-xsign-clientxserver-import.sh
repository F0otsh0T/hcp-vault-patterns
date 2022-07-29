#!/bin/sh

set -e
set -x

vault write -format=json pki-root-client/intermediate/set-signed \
    certificate=@workspace/tmp/alice/xca/pki-xsign-n7-client.pem \
    | jq > workspace/tmp/alice/xca/pki-xsign-n7-client-import.json

cat workspace/tmp/alice/xca/pki-xsign-n7-client-import.json
