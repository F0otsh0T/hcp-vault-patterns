#!/bin/sh

set -e
set -x

docker run -it mtlsxamf curl \
	-kv \
	--url https://192.168.65.2:23445 \
	--cert /vault/secrets/client-n11/client_chain.pem \
	--key /vault/secrets/client-n11/client_key.pem \
	--cacert /vault/secrets/amf_root.pem
