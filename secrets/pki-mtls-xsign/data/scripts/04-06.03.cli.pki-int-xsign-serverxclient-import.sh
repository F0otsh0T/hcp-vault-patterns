#!/bin/sh

set -e
set -x

vault write -format=json pki-int-server/intermediate/set-signed \
    certificate=@workspace/tmp/bob/xint/pki-int-xsign-n7-server.pem \
    | jq > workspace/tmp/bob/xint/pki-int-xsign-n7-server-import.json

cat workspace/tmp/bob/xint/pki-int-xsign-n7-server-import.json
