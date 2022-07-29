#!/bin/sh

set -e
set -x

vault secrets enable -path=pki-int-client pki
vault secrets tune -max-lease-ttl=87600h pki-int-client
