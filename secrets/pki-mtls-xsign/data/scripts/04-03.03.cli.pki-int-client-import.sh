#!/bin/sh

set -e
set -x

vault write -format=json pki-int-client/intermediate/set-signed \
    certificate=@workspace/tmp/alice/int/pki-int-client.pem \
    | jq > workspace/tmp/alice/int/pki-int-client-import.json

cat workspace/tmp/alice/int/pki-int-client-import.json
