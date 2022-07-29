#!/bin/sh

set -e
set -x

vault secrets disable pki-root-client
vault secrets disable pki-root-server
