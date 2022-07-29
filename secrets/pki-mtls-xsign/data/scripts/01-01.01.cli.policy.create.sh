#!/bin/sh

set -e
set -x

vault policy write pki_test data/policy/pki_test.hcl
vault policy list -format=json | jq
