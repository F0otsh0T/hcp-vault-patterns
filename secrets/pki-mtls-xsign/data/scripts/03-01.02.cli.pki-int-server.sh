#!/bin/sh

set -e
set -x

vault secrets enable -path=pki-int-server pki
vault secrets tune -max-lease-ttl=87600h pki-int-server
