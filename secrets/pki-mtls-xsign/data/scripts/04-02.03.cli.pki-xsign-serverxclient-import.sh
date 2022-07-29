#!/bin/sh

set -e
set -x

vault write -format=json pki-root-server/intermediate/set-signed \
    certificate=@workspace/tmp/bob/xca/pki-xsign-n7-server.pem \
    | jq > workspace/tmp/bob/xca/pki-xsign-n7-server-import.json

cat workspace/tmp/bob/xca/pki-xsign-n7-server-import.json
