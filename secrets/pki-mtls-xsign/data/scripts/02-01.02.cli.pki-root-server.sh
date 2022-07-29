#!/bin/sh

set -e
set -x

vault secrets enable -path=pki-root-server pki
vault secrets tune -max-lease-ttl=87600h pki-root-server
