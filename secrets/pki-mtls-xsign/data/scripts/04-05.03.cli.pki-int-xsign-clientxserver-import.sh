#!/bin/sh

set -e
set -x

vault write -format=json pki-int-client/intermediate/set-signed \
    certificate=@workspace/tmp/alice/xint/pki-int-xsign-n7-client.pem \
    | jq > workspace/tmp/alice/xint/pki-int-xsign-n7-client-import.json

cat workspace/tmp/alice/xint/pki-int-xsign-n7-client-import.json
