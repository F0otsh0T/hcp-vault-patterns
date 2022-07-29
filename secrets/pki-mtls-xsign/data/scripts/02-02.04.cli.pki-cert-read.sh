#!/bin/sh

set -e
set -x

vault read -format=json pki-root-client/cert/$(cat workspace/tmp/alice/ca/ca_root.serial_number) | jq
openssl x509 -in workspace/tmp/alice/ca/ca_root.certificate -text -noout

vault read -format=json pki-root-server/cert/$(cat workspace/tmp/bob/ca/ca_root.serial_number) | jq
openssl x509 -in workspace/tmp/bob/ca/ca_root.certificate -text -noout
