#!/bin/sh

set -e
set -x

vault write -format=json pki-int-server/intermediate/set-signed \
    certificate=@workspace/tmp/bob/int/pki-int-server.pem \
    | jq > workspace/tmp/bob/int/pki-int-server-import.json

cat workspace/tmp/bob/int/pki-int-server-import.json
