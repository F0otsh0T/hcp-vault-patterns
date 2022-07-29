#!/bin/sh

set -e
set -x

vault secrets disable pki-int-client
vault secrets disable pki-int-server
