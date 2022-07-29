#!/bin/sh

set -e
set -x

vault policy delete pki_test
vault policy list -format=json | jq
