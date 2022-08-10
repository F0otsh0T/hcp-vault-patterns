#!/bin/sh

set -e
set -x

docker exec -it mtlsxamf curl \
	-kv \
	--url https://192.168.65.2:22445 \
	--cert /vault/secrets/client-n15/client_chain.pem \
	--key /vault/secrets/client-n15/client_key.pem \
	--cacert /vault/secrets/amf_root.pem
